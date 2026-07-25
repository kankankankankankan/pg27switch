import AppKit

final class HUDWindow: NSPanel {
    private static let hudSize = NSSize(width: 500, height: 300)
    private static let shadowInset: CGFloat = 32
    private static let cornerRadius: CGFloat = 20
    private static let countdownFontSize: CGFloat = 80
    private static let cancelledFontSize: CGFloat = 72

    private let iconView = InputIconView()
    private let statusLabel = NSTextField(labelWithString: "切换屏幕输入源")
    private let targetLabel = NSTextField(labelWithString: "")
    private let countdownLabel = NSTextField(labelWithString: "")
    private let hintLabel = NSTextField(labelWithString: "ESC 取消")
    private let palette = HUDPalette.current()
    private var countdownHeightConstraint: NSLayoutConstraint?

    init(screen: NSScreen, targetName: String) {
        let size = NSSize(
            width: Self.hudSize.width + Self.shadowInset * 2,
            height: Self.hudSize.height + Self.shadowInset * 2
        )
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
        self.hasShadow = false
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
        countdownLabel.font = NSFont.monospacedDigitSystemFont(ofSize: Self.countdownFontSize, weight: .bold)
        countdownLabel.textColor = palette.primaryText
        countdownLabel.stringValue = "\(number)"
        countdownHeightConstraint?.constant = 86
        hintLabel.stringValue = "ESC 取消"
        hintLabel.textColor = palette.secondaryText
    }

    func showCancelled() {
        statusLabel.stringValue = "已取消"
        countdownLabel.stringValue = "×"
        countdownLabel.font = NSFont.systemFont(ofSize: Self.cancelledFontSize, weight: .semibold)
        countdownLabel.textColor = palette.cancelText
        countdownHeightConstraint?.constant = 86
        hintLabel.stringValue = "未切换屏幕输入源"
        hintLabel.textColor = palette.secondaryText
    }

    func showSwitching() {
        statusLabel.stringValue = "正在切换"
        countdownLabel.stringValue = "…"
        countdownLabel.font = NSFont.monospacedDigitSystemFont(ofSize: Self.countdownFontSize, weight: .bold)
        countdownLabel.textColor = palette.primaryText
        countdownHeightConstraint?.constant = 86
        hintLabel.stringValue = "请稍候"
        hintLabel.textColor = palette.secondaryText
    }

    func showFailed() {
        statusLabel.stringValue = "未完成"
        countdownLabel.stringValue = "!"
        countdownLabel.font = NSFont.systemFont(ofSize: Self.cancelledFontSize, weight: .semibold)
        countdownLabel.textColor = NSColor.systemOrange
        countdownHeightConstraint?.constant = 86
        hintLabel.stringValue = "查看日志"
        hintLabel.textColor = palette.secondaryText
    }

    private func buildContent(targetName: String) {
        let rootSize = NSSize(
            width: Self.hudSize.width + Self.shadowInset * 2,
            height: Self.hudSize.height + Self.shadowInset * 2
        )
        let rootView = HUDBackgroundView(
            frame: NSRect(origin: .zero, size: rootSize),
            hudRect: NSRect(
                x: Self.shadowInset,
                y: Self.shadowInset,
                width: Self.hudSize.width,
                height: Self.hudSize.height
            ),
            cornerRadius: Self.cornerRadius,
            palette: palette
        )
        rootView.autoresizingMask = [.width, .height]
        rootView.wantsLayer = true
        rootView.layer?.backgroundColor = NSColor.clear.cgColor
        rootView.layer?.isOpaque = false

        let stack = NSStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.distribution = .gravityAreas
        stack.spacing = 13

        configure(label: statusLabel, size: 20, weight: .regular, color: palette.secondaryText)
        configure(label: targetLabel, size: 38, weight: .semibold, color: palette.primaryText)
        configure(label: countdownLabel, size: Self.countdownFontSize, weight: .bold, color: palette.primaryText, monospaced: true)
        configure(label: hintLabel, size: 16, weight: .medium, color: palette.secondaryText)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.kind = iconKind(for: targetName)
        iconView.iconColor = palette.icon
        targetLabel.stringValue = targetName
        countdownLabel.stringValue = ""

        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(statusLabel)
        stack.addArrangedSubview(targetLabel)
        stack.addArrangedSubview(countdownLabel)
        stack.addArrangedSubview(hintLabel)

        contentView = rootView
        rootView.addSubview(stack)
        countdownHeightConstraint = countdownLabel.heightAnchor.constraint(equalToConstant: 86)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Self.shadowInset + 42),
            stack.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -(Self.shadowInset + 42)),
            stack.centerYAnchor.constraint(equalTo: rootView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 34),
            statusLabel.widthAnchor.constraint(lessThanOrEqualTo: stack.widthAnchor),
            targetLabel.widthAnchor.constraint(lessThanOrEqualTo: stack.widthAnchor),
            countdownLabel.widthAnchor.constraint(lessThanOrEqualTo: stack.widthAnchor),
            countdownHeightConstraint!,
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

private struct HUDPalette {
    let panelFill: NSColor
    let border: NSColor
    let innerHighlight: NSColor
    let shadow: NSColor
    let primaryText: NSColor
    let secondaryText: NSColor
    let cancelText: NSColor
    let icon: NSColor

    static func current() -> HUDPalette {
        let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua

        if isDark {
            return HUDPalette(
                panelFill: NSColor(calibratedWhite: 0.16, alpha: 0.96),
                border: NSColor.white.withAlphaComponent(0.10),
                innerHighlight: NSColor.white.withAlphaComponent(0.06),
                shadow: NSColor.black.withAlphaComponent(0.24),
                primaryText: NSColor.white.withAlphaComponent(0.94),
                secondaryText: NSColor.white.withAlphaComponent(0.68),
                cancelText: NSColor(red: 0.74, green: 0.43, blue: 0.41, alpha: 0.88),
                icon: NSColor.white.withAlphaComponent(0.88)
            )
        }

        return HUDPalette(
            panelFill: NSColor(calibratedWhite: 0.90, alpha: 0.98),
            border: NSColor.black.withAlphaComponent(0.18),
            innerHighlight: NSColor.white.withAlphaComponent(0.58),
            shadow: NSColor.black.withAlphaComponent(0.16),
            primaryText: NSColor.black.withAlphaComponent(0.82),
            secondaryText: NSColor.black.withAlphaComponent(0.52),
            cancelText: NSColor(red: 0.62, green: 0.36, blue: 0.35, alpha: 0.82),
            icon: NSColor.black.withAlphaComponent(0.62)
        )
    }
}

private final class HUDBackgroundView: NSView {
    private let hudRect: NSRect
    private let cornerRadius: CGFloat
    private let palette: HUDPalette

    init(frame: NSRect, hudRect: NSRect, cornerRadius: CGFloat, palette: HUDPalette) {
        self.hudRect = hudRect
        self.cornerRadius = cornerRadius
        self.palette = palette
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isOpaque: Bool {
        false
    }

    override func draw(_ dirtyRect: NSRect) {
        let panelPath = NSBezierPath(roundedRect: hudRect, xRadius: cornerRadius, yRadius: cornerRadius)

        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = palette.shadow
        shadow.shadowBlurRadius = 18
        shadow.shadowOffset = CGSize(width: 0, height: -8)
        shadow.set()
        palette.panelFill.setFill()
        panelPath.fill()
        NSGraphicsContext.restoreGraphicsState()

        palette.border.setStroke()
        panelPath.lineWidth = 1
        panelPath.stroke()

        let highlightRect = hudRect.insetBy(dx: 1, dy: 1)
        let highlightPath = NSBezierPath(roundedRect: highlightRect, xRadius: cornerRadius - 1, yRadius: cornerRadius - 1)
        palette.innerHighlight.setStroke()
        highlightPath.lineWidth = 1
        highlightPath.stroke()
    }
}
