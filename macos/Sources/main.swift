import AppKit
import Foundation

do {
    let config = try parseArguments(CommandLine.arguments)
    let logger = Logger()
    let controller = CountdownController(config: config, logger: logger)
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    app.finishLaunching()
    controller.start()
    app.run()
} catch ArgumentError.help {
    print(usage)
    exit(0)
} catch {
    fputs("\(error)\n\n\(usage)\n", stderr)
    exit(64)
}
