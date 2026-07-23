import AppKit

final class HUDWindow: NSPanel {
    private let iconView = InputIconView()
    private let statusLabel = NSTextField(labelWithString: "切换屏幕输入源")
    private let targetLabel = NSTextField(labelWithString: "")
    private let countdownLabel = NSTextField(labelWithString: "")
    private let hintLabel = NSTextField(labelWithString: "ESC 取消")

    init(screen: NSScreen, targetName: String) {
        let size = NSSize(width: 500, height: 300)
        let origin = NSPoint(
            x: screen.visibleFrame.midX - size.width / 2,
            y: screen.visibleFrame.midY - size.height / 2
        )
        let rect = NSRect(origin: origin, size: size)

        super.init(
            contentRect: rect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        self.hidesOnDeactivate = false
        self.isReleasedWhenClosed = false

        buildContent(targetName: targetName)
    }

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }

    func show(makeKey: Bool) {
        if makeKey {
            makeKeyAndOrderFront(nil)
        } else {
            orderFrontRegardless()
        }
    }

    func setCountdown(_ number: Int) {
        statusLabel.stringValue = "切换屏幕输入源"
        countdownLabel.textColor = .labelColor
        countdownLabel.stringValue = "\(number)"
        hintLabel.stringValue = "ESC 取消"
        hintLabel.textColor = .secondaryLabelColor
    }

    func showCancelled() {
        statusLabel.stringValue = "已取消"
        countdownLabel.stringValue = "×"
        countdownLabel.textColor = NSColor.systemRed
        hintLabel.stringValue = "未切换屏幕输入源"
        hintLabel.textColor = .secondaryLabelColor
    }

    func showSwitching() {
        statusLabel.stringValue = "正在切换"
        countdownLabel.stringValue = "…"
        countdownLabel.textColor = .labelColor
        hintLabel.stringValue = "请稍候"
        hintLabel.textColor = .secondaryLabelColor
    }

    func showFailed() {
        statusLabel.stringValue = "未完成"
        countdownLabel.stringValue = "!"
        countdownLabel.textColor = NSColor.systemOrange
        hintLabel.stringValue = "查看日志"
        hintLabel.textColor = .secondaryLabelColor
    }

    private func buildContent(targetName: String) {
        let effect = NSVisualEffectView()
        effect.translatesAutoresizingMaskIntoConstraints = false
        effect.material = .hudWindow
        effect.blendingMode = .behindWindow
        effect.state = .active
        effect.wantsLayer = true
        effect.layer?.cornerRadius = 34
        effect.layer?.cornerCurve = .continuous
        effect.layer?.masksToBounds = true
        effect.layer?.borderWidth = 1
        effect.layer?.borderColor = NSColor.white.withAlphaComponent(0.18).cgColor

        let stack = NSStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.distribution = .gravityAreas
        stack.spacing = 13

        configure(label: statusLabel, size: 20, weight: .regular, color: .secondaryLabelColor)
        configure(label: targetLabel, size: 38, weight: .semibold, color: .labelColor)
        configure(label: countdownLabel, size: 80, weight: .bold, color: .labelColor, monospaced: true)
        configure(label: hintLabel, size: 16, weight: .medium, color: .secondaryLabelColor)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.kind = iconKind(for: targetName)
        targetLabel.stringValue = targetName
        countdownLabel.stringValue = ""

        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(statusLabel)
        stack.addArrangedSubview(targetLabel)
        stack.addArrangedSubview(countdownLabel)
        stack.addArrangedSubview(hintLabel)

        contentView = effect
        effect.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: effect.leadingAnchor, constant: 42),
            stack.trailingAnchor.constraint(equalTo: effect.trailingAnchor, constant: -42),
            stack.centerYAnchor.constraint(equalTo: effect.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 34),
            statusLabel.widthAnchor.constraint(lessThanOrEqualTo: stack.widthAnchor),
            targetLabel.widthAnchor.constraint(lessThanOrEqualTo: stack.widthAnchor),
            countdownLabel.widthAnchor.constraint(lessThanOrEqualTo: stack.widthAnchor),
            hintLabel.widthAnchor.constraint(lessThanOrEqualTo: stack.widthAnchor)
        ])
    }

    private func iconKind(for targetName: String) -> InputIconKind {
        let normalized = targetName.lowercased()
        if normalized.contains("displayport") {
            return .displayPort
        }
        if normalized.contains("type") || normalized.contains("usb") {
            return .usbC
        }
        if normalized.contains("hdmi") {
            return .hdmi
        }
        return .display
    }

    private func configure(
        label: NSTextField,
        size: CGFloat,
        weight: NSFont.Weight,
        color: NSColor,
        monospaced: Bool = false
    ) {
        label.isEditable = false
        label.isSelectable = false
        label.isBordered = false
        label.drawsBackground = false
        label.alignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.maximumNumberOfLines = 1
        label.textColor = color

        if monospaced {
            label.font = NSFont.monospacedDigitSystemFont(ofSize: size, weight: weight)
        } else {
            label.font = NSFont.systemFont(ofSize: size, weight: weight)
        }
    }
}
