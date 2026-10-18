import Foundation

class ConverterEngine {
    private let processManager = ProcessManager()

    func convert(job: inout ConversionJob, progressHandler: ((Double) -> Void)?) async throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: job.inputURL.path) else {
            job.state = .failed(error: "Input file not found")
            throw ProcessManagerError.fileAccessError(path: job.inputURL.path, error: "File not found")
        }

        let outputURL = determineOutputPath(inputURL: job.inputURL, converter: job.converter)
        job.outputURL = outputURL

        let command = buildCommand(from: job)
        job.state = .inProgress(progress: 0)

        do {
            let toolName = job.converter.tool
            let arguments = parseCommand(command)

            _ = try await processManager.execute(tool: toolName, arguments: arguments, progressHandler: progressHandler, cancellationToken: nil)
            job.state = .succeeded
        } catch {
            job.state = .failed(error: error.localizedDescription)
            throw error
        }
    }

    func buildCommand(from job: ConversionJob) -> String {
        var command = job.converter.command
        command = command.replacingOccurrences(of: "{input}", with: job.inputURL.path)
        let outputPath = determineOutputPath(inputURL: job.inputURL, converter: job.converter).path
        command = command.replacingOccurrences(of: "{output}", with: outputPath)

        for option in job.converter.options {
            let value = job.selectedOptions[option.name] ?? option.default
            command = command.replacingOccurrences(of: "{\(option.name)}", with: value)
        }

        return command
    }

    private func determineOutputPath(inputURL: URL, converter: Converter) -> URL {
        let filename = inputURL.deletingPathExtension().lastPathComponent
        let outputExtension = converter.outputFormats.first ?? "out"
        let outputFilename = "\(filename).\(outputExtension)"
        return inputURL.deletingLastPathComponent().appendingPathComponent(outputFilename)
    }

    private func parseCommand(_ command: String) -> [String] {
        return command.split(separator: " ").map(String.init)
    }
}
