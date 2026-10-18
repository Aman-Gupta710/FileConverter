import Foundation

enum ProcessManagerError: LocalizedError {
    case nonZeroExit(code: Int, stderr: String)
    case processInterrupted
    case fileAccessError(path: String, error: String)

    var errorDescription: String? {
        switch self {
        case .nonZeroExit(let code, let stderr):
            return "Process exited with code \(code): \(stderr)"
        case .processInterrupted:
            return "Process was cancelled"
        case .fileAccessError(let path, let error):
            return "Cannot access file \(path): \(error)"
        }
    }
}

class ProcessManager {
    private let toolManager = ToolManager()

    func execute(tool: String, arguments: [String], progressHandler: ((Double) -> Void)?, cancellationToken: NSObjectProtocol?) async throws -> String {
        let toolPath = try toolManager.getToolPath(name: tool)

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = toolPath
                process.arguments = arguments

                let stdoutPipe = Pipe()
                let stderrPipe = Pipe()
                process.standardOutput = stdoutPipe
                process.standardError = stderrPipe

                do {
                    try process.run()
                    process.waitUntilExit()

                    let stdout = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
                    let stderr = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

                    if process.terminationStatus == 0 {
                        continuation.resume(returning: stdout)
                    } else {
                        continuation.resume(throwing: ProcessManagerError.nonZeroExit(code: Int(process.terminationStatus), stderr: stderr))
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
