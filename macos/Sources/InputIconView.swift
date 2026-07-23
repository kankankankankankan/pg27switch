import AppKit

enum InputIconKind {
    case displayPort
    case hdmi
    case usbC
    case display
}

final class InputIconView: NSView {
    var kind: InputIconKind = .display {
        didSet {
            needsDisplay = true
        }
    }

    override var isFlipped: Bool {
        true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let color = NSColor.labelColor.withAlphaComponent(0.9)
        color.setFill()

        switch kind {
        case .displayPort:
            drawSVGIcon(
                body: "<path fill=\"currentColor\" d=\"M1 5a1 1 0 0 0-1 1v3.191a1 1 0 0 0 .553.894l1.618.81a1 1 0 0 0 .447.105H15a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1zm1.5 2h11a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-1 0V8H3v.5a.5.5 0 0 1-1 0v-1a.5.5 0 0 1 .5-.5\"/>",
                viewBox: "0 0 16 16",
                in: bounds.insetBy(dx: 5, dy: 5),
                color: color
            )
        case .hdmi:
            drawHDMIPort(in: bounds.insetBy(dx: 4, dy: 5), color: color)
        case .usbC:
            drawSVGIcon(
                body: "<path fill=\"currentColor\" d=\"M6 12h12c.55 0 1 .45 1 1s-.45 1-1 1H6c-.55 0-1-.45-1-1s.45-1 1-1m0-2c-1.66 0-3 1.34-3 3s1.34 3 3 3h12c1.66 0 3-1.34 3-3s-1.34-3-3-3zm0-2h12c2.76 0 5 2.24 5 5s-2.24 5-5 5H6c-2.76 0-5-2.24-5-5s2.24-5 5-5\"/>",
                viewBox: "0 0 24 24",
                in: bounds.insetBy(dx: 5, dy: 3),
                color: color
            )
        case .display:
            drawSVGIcon(
                body: "<path fill=\"currentColor\" d=\"M21 16H3V4h18m0-2H3c-1.11 0-2 .89-2 2v12a2 2 0 0 0 2 2h7v2H8v2h8v-2h-2v-2h7a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2\"/>",
                viewBox: "0 0 24 24",
                in: bounds.insetBy(dx: 4, dy: 3),
                color: color
            )
        }
    }

    private func drawSVGIcon(body: String, viewBox: String, in rect: NSRect, color: NSColor) {
        let srgb = color.usingColorSpace(.sRGB) ?? NSColor.white.withAlphaComponent(0.9)
        let red = Int(round(srgb.redComponent * 255))
        let green = Int(round(srgb.greenComponent * 255))
        let blue = Int(round(srgb.blueComponent * 255))
        let alpha = String(format: "%.3f", srgb.alphaComponent)
        let fill = String(format: "#%02X%02X%02X", red, green, blue)
        let tintedBody = body
            .replacingOccurrences(of: "fill=\"currentColor\"", with: "fill=\"\(fill)\" fill-opacity=\"\(alpha)\"")
        let svg = """
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="\(viewBox)">\(tintedBody)</svg>
        """

        guard
            let data = svg.data(using: .utf8),
            let image = NSImage(data: data)
        else {
            return
        }

        image.draw(
            in: rect,
            from: .zero,
            operation: .sourceOver,
            fraction: 1,
            respectFlipped: true,
            hints: nil
        )
    }

    private func drawHDMIPort(in rect: NSRect, color: NSColor) {
        let scale = min(rect.width / 64, rect.height / 25)
        let width = 64 * scale
        let height = 25 * scale
        let origin = NSPoint(x: rect.midX - width / 2, y: rect.midY - height / 2)

        func point(_ x: CGFloat, _ y: CGFloat) -> NSPoint {
            NSPoint(x: origin.x + x * scale, y: origin.y + y * scale)
        }

        func rectangle(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> NSRect {
            NSRect(x: origin.x + x * scale, y: origin.y + y * scale, width: width * scale, height: height * scale)
        }

        let port = NSBezierPath()
        port.windingRule = .evenOdd
        port.move(to: point(5.5, 1))
        port.line(to: point(58.5, 1))
        port.curve(to: point(64, 6.5), controlPoint1: point(61.6, 1), controlPoint2: point(64, 3.4))
        port.line(to: point(64, 13.8))
        port.curve(to: point(58.7, 18.2), controlPoint1: point(64, 16.5), controlPoint2: point(61.5, 17.6))
        port.curve(to: point(52.2, 23), controlPoint1: point(55, 19), controlPoint2: point(54.9, 21.3))
        port.curve(to: point(48.8, 24), controlPoint1: point(51.2, 23.6), controlPoint2: point(50.2, 24))
        port.line(to: point(15.2, 24))
        port.curve(to: point(11.8, 23), controlPoint1: point(13.8, 24), controlPoint2: point(12.8, 23.6))
        port.curve(to: point(5.3, 18.2), controlPoint1: point(9.1, 21.3), controlPoint2: point(9, 19))
        port.curve(to: point(0, 13.8), controlPoint1: point(2.5, 17.6), controlPoint2: point(0, 16.5))
        port.line(to: point(0, 6.5))
        port.curve(to: point(5.5, 1), controlPoint1: point(0, 3.4), controlPoint2: point(2.4, 1))
        port.close()

        port.move(to: point(6.4, 4.2))
        port.line(to: point(57.6, 4.2))
        port.curve(to: point(60.7, 7.3), controlPoint1: point(59.4, 4.2), controlPoint2: point(60.7, 5.5))
        port.line(to: point(60.7, 13.2))
        port.curve(to: point(59.4, 14.4), controlPoint1: point(60.7, 13.8), controlPoint2: point(60.2, 14.2))
        port.curve(to: point(50.5, 20.5), controlPoint1: point(54.1, 15.1), controlPoint2: point(53.9, 18.1))
        port.curve(to: point(48.4, 21), controlPoint1: point(49.9, 20.8), controlPoint2: point(49.2, 21))
        port.line(to: point(15.6, 21))
        port.curve(to: point(13.5, 20.5), controlPoint1: point(14.8, 21), controlPoint2: point(14.1, 20.8))
        port.curve(to: point(4.6, 14.4), controlPoint1: point(10.1, 18.1), controlPoint2: point(9.9, 15.1))
        port.curve(to: point(3.3, 13.2), controlPoint1: point(3.8, 14.2), controlPoint2: point(3.3, 13.8))
        port.line(to: point(3.3, 7.3))
        port.curve(to: point(6.4, 4.2), controlPoint1: point(3.3, 5.5), controlPoint2: point(4.6, 4.2))
        port.close()

        color.setFill()
        port.fill()

        let contacts = NSBezierPath(rect: rectangle(x: 18.5, y: 11.4, width: 27, height: 2.8))
        for index in 0..<10 {
            let x = 18.5 + CGFloat(index) * 2.7
            contacts.append(NSBezierPath(rect: rectangle(x: x, y: 9.4, width: 1.7, height: 2.2)))
            contacts.append(NSBezierPath(rect: rectangle(x: x, y: 14.1, width: 1.7, height: 2.2)))
        }
        color.setFill()
        contacts.fill()
    }
}
