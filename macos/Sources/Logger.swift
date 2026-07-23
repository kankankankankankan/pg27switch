import Foundation

final class Logger {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "PG27UCDMSwitcher.Logger")

    init() {
        let fileManager = FileManager.default
        let home = fileManager.homeDirectoryForCurrentUser
        let preferred = home
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Logs", isDirectory: true)
            .appendingPathComponent("PG27UCDMSwitcher", isDirectory: true)

        let fallback = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("PG27UCDMSwitcher", isDirectory: true)

        if Self.prepare(directory: preferred) {
            self.fileURL = preferred.appendingPathComponent("pg27switch.log")
        } else {
            _ = Self.prepare(directory: fallback)
            self.fileURL = fallback.appendingPathComponent("pg27switch.log")
        }
    }

    func write(_ message: String) {
        let line = "\(Self.timestamp()) \(message)\n"
        queue.sync {
            if let data = line.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    if let handle = try? FileHandle(forWritingTo: fileURL) {
                        defer { try? handle.close() }
                        _ = try? handle.seekToEnd()
                        try? handle.write(contentsOf: data)
                    }
                } else {
                    try? data.write(to: fileURL)
                }
            }
        }
    }

    private static func timestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: Date())
    }

    private static func prepare(directory: URL) -> Bool {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let probe = directory.appendingPathComponent(".write-test")
            try Data().write(to: probe)
            try? FileManager.default.removeItem(at: probe)
            return true
        } catch {
            return false
        }
    }
}
