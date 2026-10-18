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

        // Run async code synchronously
        let semaphore = DispatchSemaphore(value: 0)
        var conversionError: Error?

        Task {
            do {
                let configLoader = ConfigLoader()
                let converters = try await configLoader.loadDefaultConverters()

                // Find suitable converter based on file extension
                let suitableConverters = converters.filter { converter in
                    converter.inputFormats.contains(inputExt)
                }

                guard !suitableConverters.isEmpty else {
                    print("Error: No converter found for .\(inputExt) files")
                    print("Use 'fileconverter list' to see supported formats")
                    semaphore.signal()
                    return
                }

                let converter = suitableConverters[0]
                print("📁 Converting: \(inputURL.lastPathComponent)")
                print("🔧 Using converter: \(converter.name)")
                print("📝 Command: \(converter.command)")

                let engine = ConverterEngine(converter: converter)

                // Parse additional options from command line
                var options: [String: String] = [:]
                var i = 2
                while i < arguments.count {
                    if arguments[i] == "--option" && i + 1 < arguments.count {
                        let parts = arguments[i + 1].split(separator: "=", maxSplits: 1)
                        if parts.count == 2 {
                            options[String(parts[0])] = String(parts[1])
                        }
                        i += 2
                    } else {
                        i += 1
                    }
                }

                var job = ConversionJob(
                    inputURL: inputURL,
                    converter: converter,
                    selectedOptions: options
                )

                try await engine.convert(job: &job) { progress in
                    print("Progress: \(Int(progress * 100))%")
                }

                print("✅ Conversion successful!")
                if let resultURL = job.outputURL {
                    print("📂 Output: \(resultURL.path)")
                }

            } catch {
                print("❌ Error: \(error.localizedDescription)")
                conversionError = error
            }
            semaphore.signal()
        }

        semaphore.wait()
        exit(conversionError != nil ? 1 : 0)
    }

    private static func handleList() {
        // Run async code synchronously
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let configLoader = ConfigLoader()
                let converters = try await configLoader.loadDefaultConverters()

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
                        print("    ID: \(converter.id)")
                    }
                    print()
                }

            } catch {
                print("Error: \(error.localizedDescription)")
            }
            semaphore.signal()
        }

        semaphore.wait()
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
            fileconverter convert document.pdf document-compressed.pdf
            fileconverter list

        SUPPORTED FORMATS:
            Images:    JPEG, PNG, WebP, GIF
            Video:     MP4, MOV, AVI, MKV
            Audio:     MP3, WAV, AAC, FLAC
            Documents: PDF (compression)

        For more info, visit: https://github.com/Aman-Gupta710/FileConverter
        """)
    }
}

// Entry point
FileConverterCLI.main()
