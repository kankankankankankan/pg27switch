import AppKit

final class HUDWindow: NSPanel {
    private static let hudSize = NSSize(width: 500, height: 300)
    private static let shadowInset: CGFloat = 32
    private static let cornerRadius: CGFloat = 20
    private static let countdownFontSize: CGFloat = 72
    private static let cancelledFontSize: CGFloat = 68
    private let iconView = InputIconView()
    private let statusLabel = NSTextField(labelWithString: "切换屏幕输入源")
    private let targetLabel = NSTextField(labelWithString: "")
    private let countdownLabel = NSTextField(labelWithString: "")
    private let hintLabel = NSTextField(labelWithString: "ESC 取消")
    private let palette: HUDPalette
    private var countdownHeightConstraint: NSLayoutConstraint?

    init(screen: NSScreen, targetName: String, theme: HUDTheme) {
        self.palette = HUDPalette.current(theme)
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
        countdownHeightConstraint?.constant = 78
        hintLabel.stringValue = "ESC 取消"
        hintLabel.textColor = palette.secondaryText
    }

    func showCancelled() {
        statusLabel.stringValue = "已取消"
        countdownLabel.stringValue = "×"
        countdownLabel.font = NSFont.systemFont(ofSize: Self.cancelledFontSize, weight: .semibold)
        countdownLabel.textColor = palette.cancelText
        countdownHeightConstraint?.constant = 78
        hintLabel.stringValue = "未切换屏幕输入源"
        hintLabel.textColor = palette.secondaryText
    }

    func showSwitching() {
        statusLabel.stringValue = "正在切换"
        countdownLabel.stringValue = "…"
        countdownLabel.font = NSFont.monospacedDigitSystemFont(ofSize: Self.countdownFontSize, weight: .bold)
        countdownLabel.textColor = palette.primaryText
        countdownHeightConstraint?.constant = 78
        hintLabel.stringValue = "请稍候"
        hintLabel.textColor = palette.secondaryText
    }

    func showFailed() {
        statusLabel.stringValue = "未完成"
        countdownLabel.stringValue = "!"
        countdownLabel.font = NSFont.systemFont(ofSize: Self.cancelledFontSize, weight: .semibold)
        countdownLabel.textColor = NSColor.systemOrange
        countdownHeightConstraint?.constant = 78
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
        stack.spacing = 11

        configure(label: statusLabel, size: 18, weight: .regular, color: palette.secondaryText)
        configure(label: targetLabel, size: 35, weight: .semibold, color: palette.primaryText)
        configure(label: countdownLabel, size: Self.countdownFontSize, weight: .bold, color: palette.primaryText, monospaced: true)
        configure(label: hintLabel, size: 16, weight: .medium, color: palette.secondaryText)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.kind = iconKind(for: targetName)
        iconView.iconColor = palette.icon
        targetLabel.stringValue = targetName
        countdownLabel.stringValue = ""

        stack.addArrangedSubview(statusLabel)
        stack.addArrangedSubview(targetLabel)
        stack.addArrangedSubview(countdownLabel)
        stack.addArrangedSubview(hintLabel)

        contentView = rootView
        rootView.addSubview(iconView)
        rootView.addSubview(stack)
        countdownHeightConstraint = countdownLabel.heightAnchor.constraint(equalToConstant: 78)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: Self.shadowInset + 42),
            stack.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -(Self.shadowInset + 42)),
            stack.centerYAnchor.constraint(equalTo: rootView.centerYAnchor, constant: 16),
            iconView.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: rootView.topAnchor, constant: Self.shadowInset + 1),
            iconView.widthAnchor.constraint(equalToConstant: 34),
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
    let accent: NSColor
    let headerFill: NSColor
    let quietLine: NSColor
    let gold: NSColor
    let bottomMark: NSColor

    static func current(_ theme: HUDTheme) -> HUDPalette {
        let isDark: Bool
        switch theme {
        case .dark:
            isDark = true
        case .light:
            isDark = false
        case .system:
            isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }

        if isDark {
            return HUDPalette(
                panelFill: NSColor(red: 0.060, green: 0.058, blue: 0.060, alpha: 0.985),
                border: NSColor(red: 0.86, green: 0.06, blue: 0.09, alpha: 0.46),
                innerHighlight: NSColor.white.withAlphaComponent(0.045),
                shadow: NSColor.black.withAlphaComponent(0.32),
                primaryText: NSColor.white.withAlphaComponent(0.95),
                secondaryText: NSColor.white.withAlphaComponent(0.62),
                cancelText: NSColor(red: 0.92, green: 0.08, blue: 0.11, alpha: 0.92),
                icon: NSColor(red: 0.92, green: 0.08, blue: 0.11, alpha: 0.88),
                accent: NSColor(red: 0.92, green: 0.08, blue: 0.11, alpha: 0.86),
                headerFill: NSColor(red: 0.92, green: 0.08, blue: 0.11, alpha: 0.095),
                quietLine: NSColor.white.withAlphaComponent(0.075),
                gold: NSColor(red: 0.82, green: 0.66, blue: 0.36, alpha: 0.48),
                bottomMark: NSColor.white.withAlphaComponent(0.086)
            )
        }

        return HUDPalette(
            panelFill: NSColor(red: 0.948, green: 0.948, blue: 0.952, alpha: 0.98),
            border: NSColor(red: 0.74, green: 0.06, blue: 0.08, alpha: 0.30),
            innerHighlight: NSColor.white.withAlphaComponent(0.78),
            shadow: NSColor.black.withAlphaComponent(0.17),
            primaryText: NSColor(red: 0.075, green: 0.070, blue: 0.075, alpha: 0.88),
            secondaryText: NSColor(red: 0.075, green: 0.070, blue: 0.075, alpha: 0.55),
            cancelText: NSColor(red: 0.72, green: 0.06, blue: 0.08, alpha: 0.86),
            icon: NSColor(red: 0.74, green: 0.06, blue: 0.08, alpha: 0.78),
            accent: NSColor(red: 0.74, green: 0.06, blue: 0.08, alpha: 0.64),
            headerFill: NSColor(red: 0.74, green: 0.06, blue: 0.08, alpha: 0.060),
            quietLine: NSColor.black.withAlphaComponent(0.080),
            gold: NSColor(red: 0.66, green: 0.50, blue: 0.22, alpha: 0.36),
            bottomMark: NSColor.black.withAlphaComponent(0.067)
        )
    }
}

private final class HUDBackgroundView: NSView {
    private static let headerHeight: CGFloat = 34

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

        NSGraphicsContext.saveGraphicsState()
        panelPath.addClip()
        palette.headerFill.setFill()
        NSRect(x: hudRect.minX, y: hudRect.maxY - Self.headerHeight, width: hudRect.width, height: Self.headerHeight).fill()
        palette.accent.setFill()
        NSRect(x: hudRect.minX, y: hudRect.maxY - 3, width: hudRect.width, height: 3).fill()
        palette.quietLine.setFill()
        NSRect(x: hudRect.minX + 92, y: hudRect.maxY - Self.headerHeight, width: hudRect.width - 184, height: 1).fill()
        NSGraphicsContext.restoreGraphicsState()

        palette.border.setStroke()
        panelPath.lineWidth = 1
        panelPath.stroke()

        let highlightRect = hudRect.insetBy(dx: 1, dy: 1)
        let highlightPath = NSBezierPath(roundedRect: highlightRect, xRadius: cornerRadius - 1, yRadius: cornerRadius - 1)
        palette.innerHighlight.setStroke()
        highlightPath.lineWidth = 1
        highlightPath.stroke()

        for index in 0..<3 {
            drawChevron(
                origin: NSPoint(x: hudRect.minX + 24 + CGFloat(index) * 12, y: hudRect.maxY - 25),
                color: palette.accent.withAlphaComponent(palette.accent.alphaComponent * 0.58)
            )
        }

        drawGoldTicks(in: hudRect)
        drawCornerLines(in: hudRect)
        drawSideRail(in: hudRect)
        drawMicroGrid(in: hudRect)
        drawBottomStrip(in: hudRect)
    }

    private func drawChevron(origin: NSPoint, color: NSColor) {
        let path = NSBezierPath()
        path.move(to: origin)
        path.line(to: NSPoint(x: origin.x + 8, y: origin.y))
        path.line(to: NSPoint(x: origin.x + 14, y: origin.y + 6))
        path.line(to: NSPoint(x: origin.x + 8, y: origin.y + 6))
        path.close()
        color.setFill()
        path.fill()
    }

    private func drawGoldTicks(in rect: NSRect) {
        let path = NSBezierPath()
        path.move(to: NSPoint(x: rect.maxX - 78, y: rect.maxY - 18))
        path.line(to: NSPoint(x: rect.maxX - 38, y: rect.maxY - 18))
        path.move(to: NSPoint(x: rect.maxX - 62, y: rect.minY + 22))
        path.line(to: NSPoint(x: rect.maxX - 28, y: rect.minY + 22))
        palette.gold.setStroke()
        path.lineWidth = 1
        path.stroke()
    }

    private func drawCornerLines(in rect: NSRect) {
        let left = NSRect(x: rect.minX + 24, y: rect.minY + 20, width: 54, height: 28)
        let right = NSRect(x: rect.maxX - 78, y: rect.minY + 20, width: 54, height: 28)
        palette.quietLine.withAlphaComponent(palette.quietLine.alphaComponent * 0.38).setStroke()

        let path = NSBezierPath()
        path.move(to: NSPoint(x: left.minX, y: left.maxY))
        path.line(to: NSPoint(x: left.minX, y: left.minY))
        path.line(to: NSPoint(x: left.maxX, y: left.minY))
        path.move(to: NSPoint(x: right.maxX, y: right.maxY))
        path.line(to: NSPoint(x: right.maxX, y: right.minY))
        path.line(to: NSPoint(x: right.minX, y: right.minY))
        path.lineWidth = 2
        path.stroke()
    }

    private func drawSideRail(in rect: NSRect) {
        let x = rect.maxX - 24
        let y = rect.maxY - 108
        palette.accent.withAlphaComponent(palette.accent.alphaComponent * 0.18).setStroke()

        let path = NSBezierPath()
        path.move(to: NSPoint(x: x, y: y))
        path.line(to: NSPoint(x: x, y: y + 52))
        path.move(to: NSPoint(x: x - 18, y: y + 52))
        path.line(to: NSPoint(x: x, y: y + 52))
        path.move(to: NSPoint(x: x - 18, y: y))
        path.line(to: NSPoint(x: x, y: y))
        path.lineWidth = 1
        path.stroke()
    }

    private func drawMicroGrid(in rect: NSRect) {
        palette.quietLine.withAlphaComponent(palette.quietLine.alphaComponent * 0.12).setStroke()

        let gridRect = NSRect(x: rect.minX + 26, y: rect.maxY - 88, width: 36, height: 26)
        let path = NSBezierPath()
        var x = gridRect.minX
        while x <= gridRect.maxX {
            path.move(to: NSPoint(x: x, y: gridRect.minY))
            path.line(to: NSPoint(x: x, y: gridRect.maxY))
            x += 9
        }
        var y = gridRect.minY
        while y <= gridRect.maxY {
            path.move(to: NSPoint(x: gridRect.minX, y: y))
            path.line(to: NSPoint(x: gridRect.maxX, y: y))
            y += 9
        }
        path.lineWidth = 1
        path.stroke()
    }

    private func drawBottomStrip(in rect: NSRect) {
        let y = rect.minY + 13
        let centerX = rect.midX
        let color = palette.bottomMark
        color.set()

        let flowAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold),
            .foregroundColor: color
        ]
        NSAttributedString(string: "0>>>1", attributes: flowAttributes).draw(at: NSPoint(x: centerX - 86, y: y - 3))

        let dots = NSBezierPath()
        for row in 0..<2 {
            for column in 0..<6 {
                let dotRect = NSRect(
                    x: centerX - 36 + CGFloat(column) * 6,
                    y: y + CGFloat(row) * 5,
                    width: 2,
                    height: 2
                )
                dots.appendOval(in: dotRect)
            }
        }
        color.setFill()
        dots.fill()

        let hatch = NSBezierPath()
        for index in 0..<5 {
            let startX = centerX + 12 + CGFloat(index) * 5
            hatch.move(to: NSPoint(x: startX, y: y))
            hatch.line(to: NSPoint(x: startX + 8, y: y + 8))
        }
        color.setStroke()
        hatch.lineWidth = 2
        hatch.stroke()

        let scan = NSBezierPath()
        for index in 0..<7 {
            let x = centerX + 54 + CGFloat(index) * 5
            scan.move(to: NSPoint(x: x, y: y))
            scan.line(to: NSPoint(x: x + 2, y: y))
        }
        scan.lineWidth = 1
        scan.stroke()
    }

}
