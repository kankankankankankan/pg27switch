import AppKit

final class CountdownController {
    private let config: SwitchConfig
    private let logger: Logger
    private let betterDisplay: BetterDisplayClient
    private var windows: [HUDWindow] = []
    private var remaining: Int
    private var timer: Timer?
    private var eventMonitor: Any?
    private var isFinishing = false

    init(config: SwitchConfig, logger: Logger) {
        self.config = config
        self.logger = logger
        self.remaining = config.seconds
        self.betterDisplay = BetterDisplayClient(executablePath: config.betterDisplayPath, logger: logger)
    }

    func start() {
        logger.write("Starting pg27switch name=\(config.name) value=\(String(describing: config.value)) preview=\(config.previewOnly)")
        logger.write("Screens detected: \(NSScreen.screens.count)")

        NSApp.activate(ignoringOtherApps: true)

        windows = NSScreen.screens.enumerated().map { index, screen in
            logger.write("Screen \(index): frame=\(screen.frame) visible=\(screen.visibleFrame)")
            return HUDWindow(screen: screen, targetName: config.name)
        }

        for (index, window) in windows.enumerated() {
            window.show(makeKey: index == 0)
        }

        installEscapeMonitor()
        tick()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard !isFinishing else { return }

        if remaining > 0 {
            windows.forEach { $0.setCountdown(remaining) }
            remaining -= 1
            return
        }

        finishSwitch()
    }

    private func installEscapeMonitor() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            if event.keyCode == 53 {
                self?.cancel()
                return nil
            }
            return event
        }
    }

    private func cancel() {
        guard !isFinishing else { return }
        isFinishing = true
        timer?.invalidate()
        logger.write("Cancelled by ESC")
        windows.forEach { $0.showCancelled() }
        closeAfterDelay(status: 0, delay: 0.75)
    }

    private func finishSwitch() {
        guard !isFinishing else { return }
        isFinishing = true
        timer?.invalidate()

        if config.previewOnly {
            logger.write("Preview finished without DDC call")
            closeAfterDelay(status: 0, delay: 0.15)
            return
        }

        guard let value = config.value else {
            logger.write("Missing value at switch time")
            windows.forEach { $0.showFailed() }
            closeAfterDelay(status: 2, delay: 1.2)
            return
        }

        windows.forEach { $0.showSwitching() }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try self.betterDisplay.switchInput(value: value)
                self.logger.write("BetterDisplay exit=\(result.terminationStatus) stdout=\(result.stdout) stderr=\(result.stderr)")
                DispatchQueue.main.async {
                    if result.terminationStatus == 0 {
                        self.closeAfterDelay(status: 0, delay: 0.0)
                    } else {
                        self.windows.forEach { $0.showFailed() }
                        self.closeAfterDelay(status: Int(result.terminationStatus), delay: 1.5)
                    }
                }
            } catch {
                self.logger.write("BetterDisplay error: \(error)")
                DispatchQueue.main.async {
                    self.windows.forEach { $0.showFailed() }
                    self.closeAfterDelay(status: 1, delay: 1.5)
                }
            }
        }
    }

    private func closeAfterDelay(status: Int, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if let monitor = self.eventMonitor {
                NSEvent.removeMonitor(monitor)
            }
            self.windows.forEach { $0.close() }
            NSApp.terminate(nil)
            exit(Int32(status))
        }
    }
}
