import Foundation

enum ToolManagerError: LocalizedError {
    case toolNotFound(name: String)
    case notExecutable(path: String)

    var errorDescription: String? {
        switch self {
        case .toolNotFound(let name):
            return "Tool not found: \(name). Install via Homebrew: brew install \(name)"
        case .notExecutable(let path):
            return "Tool exists but is not executable: \(path)"
        }
    }
}

public class ToolManager {
    private let bundledToolsPath: URL

    public init() {
        bundledToolsPath = Bundle.main.bundleURL
            .appendingPathComponent("Contents/Resources/Tools")
    }

    public func getToolPath(name: String) throws -> URL {
        if let bundledPath = getBundledToolPath(name: name) {
            return bundledPath
        }

        if let systemPath = findInSystemPath(name: name) {
            return systemPath
        }

        throw ToolManagerError.toolNotFound(name: name)
    }

    func isBundledToolAvailable(name: String) -> Bool {
        return FileManager.default.fileExists(atPath: getBundledToolPath(name: name)?.path ?? "")
    }

    private func getBundledToolPath(name: String) -> URL? {
        let toolPath = bundledToolsPath.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: toolPath.path) else {
            return nil
        }

        let attributes = try? FileManager.default.attributesOfItem(atPath: toolPath.path)
        let permissions = attributes?[FileAttributeKey.posixPermissions] as? NSNumber
        let isExecutable = (permissions?.intValue ?? 0) & 0o111 != 0

        return isExecutable ? toolPath : nil
    }

    func findInSystemPath(name: String) -> URL? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "which \(name)"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !path.isEmpty {
                return URL(fileURLWithPath: path)
            }
        } catch {
            return nil
        }

        return nil
    }
}
