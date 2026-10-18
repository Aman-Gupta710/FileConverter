import Foundation
import FileConverterCore

struct FileConverterCLI {
    static func main() {
        let arguments = CommandLine.arguments

        if arguments.count < 2 {
            printUsage()
            exit(0)
        }

        let command = arguments[1]

        switch command {
        case "convert":
            handleConvert(arguments: Array(arguments.dropFirst(2)))
        case "list":
            handleList()
        case "help", "--help", "-h":
            printUsage()
        default:
            print("Unknown command: \(command)")
            printUsage()
            exit(1)
        }
    }

    private static func handleConvert(arguments: [String]) {
        guard arguments.count >= 2 else {
            print("Error: convert requires input and output files")
            print("Usage: fileconverter convert <input> <output>")
            exit(1)
        }

        let inputPath = arguments[0]
        let outputPath = arguments[1]

        // Verify input file exists
        guard FileManager.default.fileExists(atPath: inputPath) else {
            print("Error: Input file not found: \(inputPath)")
            exit(1)
        }

        let inputURL = URL(fileURLWithPath: inputPath)
        let outputURL = URL(fileURLWithPath: outputPath)
        let inputExt = inputURL.pathExtension.lowercased()

        do {
            let configLoader = ConfigLoader()

            // Use RunLoop to execute async code
            var converters: [Converter] = []
            var loadError: Error?

            let semaphore = DispatchSemaphore(value: 0)
            DispatchQueue.global().async {
                Task {
                    do {
                        converters = try await configLoader.loadDefaultConverters()
                    } catch {
                        loadError = error
                    }
                    semaphore.signal()
                }
            }

            // Wait with timeout
            let result = semaphore.wait(timeout: .now() + 10.0)

            if result == .timedOut {
                print("Error: Timeout loading converters")
                exit(1)
            }

            if let error = loadError {
                print("Error: \(error.localizedDescription)")
                exit(1)
            }

            // Find suitable converter based on file extension
            let suitableConverters = converters.filter { converter in
                converter.inputFormats.contains(inputExt)
            }

            guard !suitableConverters.isEmpty else {
                print("Error: No converter found for .\(inputExt) files")
                print("Use 'fileconverter list' to see supported formats")
                exit(1)
            }

            let converter = suitableConverters[0]
            print("📁 Converting: \(inputURL.lastPathComponent)")
            print("🔧 Using: \(converter.name)")
            print("Tool: \(converter.tool)")
            print("Command: \(converter.command)")

            let engine = ConverterEngine(converter: converter)

            var job = ConversionJob(
                inputURL: inputURL,
                converter: converter
            )

            let conversionSemaphore = DispatchSemaphore(value: 0)
            var conversionError: Error?

            DispatchQueue.global().async {
                Task {
                    do {
                        try await engine.convert(job: &job) { progress in
                            print("Progress: \(Int(progress * 100))%")
                        }
                    } catch {
                        conversionError = error
                    }
                    conversionSemaphore.signal()
                }
            }

            let convResult = conversionSemaphore.wait(timeout: .now() + 300.0)

            if convResult == .timedOut {
                print("Error: Conversion timeout")
                exit(1)
            }

            if let error = conversionError {
                print("Error: \(error.localizedDescription)")
                exit(1)
            }

            print("✅ Conversion successful!")
            print("Output: \(outputPath)")

        } catch {
            print("Error: \(error.localizedDescription)")
            exit(1)
        }
    }

    private static func handleList() {
        let configLoader = ConfigLoader()

        let semaphore = DispatchSemaphore(value: 0)
        var converters: [Converter] = []
        var loadError: Error?

        DispatchQueue.global().async {
            Task {
                do {
                    converters = try await configLoader.loadDefaultConverters()
                } catch {
                    loadError = error
                }
                semaphore.signal()
            }
        }

        let result = semaphore.wait(timeout: .now() + 10.0)

        if result == .timedOut {
            print("Error: Timeout loading converters")
            exit(1)
        }

        if let error = loadError {
            print("Error: \(error.localizedDescription)")
            exit(1)
        }

        if converters.isEmpty {
            print("No converters found")
            exit(1)
        }

        print("\n📋 Available Converters:\n")

        var categories: [String: [Converter]] = [:]
        for converter in converters {
            if categories[converter.category] == nil {
                categories[converter.category] = []
            }
            categories[converter.category]?.append(converter)
        }

        for (category, converters) in categories.sorted(by: { $0.key < $1.key }) {
            print("[\(category.uppercased())]")
            for converter in converters {
                let inputFormats = converter.inputFormats.joined(separator: ", ")
                let outputFormats = converter.outputFormats.joined(separator: ", ")
                print("  • \(converter.name)")
                print("    Input: \(inputFormats)")
                print("    Output: \(outputFormats)")
            }
            print()
        }
    }

    private static func printUsage() {
        print("""
        FileConverter CLI - Offline file format conversion

        USAGE:
            fileconverter convert <input> <output>  Convert a file
            fileconverter list                        List available converters
            fileconverter help                        Show this help message

        EXAMPLES:
            fileconverter convert photo.jpg photo.png
            fileconverter convert video.mp4 video.mov

        SUPPORTED FORMATS:
            Images:    JPEG, PNG, WebP, GIF
            Video:     MP4, MOV, AVI, MKV
            Audio:     MP3, WAV, AAC, FLAC
            Documents: PDF
        """)
    }
}

FileConverterCLI.main()
