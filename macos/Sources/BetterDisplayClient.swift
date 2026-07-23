import Foundation

struct BetterDisplayResult {
    let terminationStatus: Int32
    let stdout: String
    let stderr: String
}

final class BetterDisplayClient {
    private let executablePath: String
    private let logger: Logger

    init(executablePath: String, logger: Logger) {
        self.executablePath = executablePath
        self.logger = logger
    }

    func switchInput(value: Int) throws -> BetterDisplayResult {
        guard FileManager.default.isExecutableFile(atPath: executablePath) else {
            throw RuntimeError("BetterDisplay executable not found: \(executablePath)")
        }

        let primary = ["set", "-namelike=PG27UCDM", "-ddc=\(value)", "-vcp=inputSelect"]
        let fallback = ["set", "-namelike=PG27UCDM", "-feature=ddc", "-vcp=inputSelect", "-value=\(value)"]

        logger.write("Running BetterDisplay primary syntax: \(primary.joined(separator: " "))")
        let first = run(arguments: primary)
        if first.terminationStatus == 0 {
            return first
        }

        logger.write("Primary syntax failed with \(first.terminationStatus). stderr: \(first.stderr)")
        logger.write("Running BetterDisplay fallback syntax: \(fallback.joined(separator: " "))")
        return run(arguments: fallback)
    }

    private func run(arguments: [String]) -> BetterDisplayResult {
        let process = Process()
        let output = Pipe()
        let error = Pipe()

        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments
        process.standardOutput = output
        process.standardError = error

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return BetterDisplayResult(terminationStatus: 127, stdout: "", stderr: error.localizedDescription)
        }

        let stdoutData = output.fileHandleForReading.readDataToEndOfFile()
        let stderrData = error.fileHandleForReading.readDataToEndOfFile()
        return BetterDisplayResult(
            terminationStatus: process.terminationStatus,
            stdout: String(data: stdoutData, encoding: .utf8) ?? "",
            stderr: String(data: stderrData, encoding: .utf8) ?? ""
        )
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var description: String {
        message
    }
}
