import Foundation

public enum ConfigLoaderError: LocalizedError {
    case fileNotFound(path: String)
    case invalidYAML(error: String)
    case missingRequiredField(field: String)
    case invalidSchema(detail: String)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "Config file not found: \(path)"
        case .invalidYAML(let error):
            return "Invalid YAML: \(error)"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidSchema(let detail):
            return "Invalid converter schema: \(detail)"
        }
    }
}

public class ConfigLoader {
    public init() {}

    public func loadConverters(from url: URL) async throws -> [Converter] {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else {
            throw ConfigLoaderError.fileNotFound(path: url.path)
        }

        let yaml = try String(contentsOf: url, encoding: .utf8)
        let decoder = YAMLDecoder()

        let configDict = try decoder.decode([String: Any].self, from: yaml)
        guard let convertersArray = configDict["converters"] as? [[String: Any]] else {
            throw ConfigLoaderError.invalidYAML(error: "Top-level structure invalid")
        }

        var converters: [Converter] = []

        for (index, converterDict) in convertersArray.enumerated() {
            guard converterDict["id"] != nil,
                  converterDict["name"] != nil,
                  converterDict["command"] != nil,
                  converterDict["tool"] != nil else {
                throw ConfigLoaderError.missingRequiredField(field: "converter[\(index)]: missing required field")
            }

            let jsonData = try JSONSerialization.data(withJSONObject: converterDict)
            do {
                let converter = try JSONDecoder().decode(Converter.self, from: jsonData)
                converters.append(converter)
            } catch {
                throw ConfigLoaderError.invalidSchema(detail: "Converter \(index): \(error.localizedDescription)")
            }
        }

        return converters
    }

    public func loadDefaultConverters() async throws -> [Converter] {
        // Try multiple locations for converters.yaml
        let possiblePaths = [
            Bundle.main.url(forResource: "converters", withExtension: "yaml"),
            URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("converters.yaml"),
            URL(fileURLWithPath: "/usr/local/etc/fileconverter/converters.yaml"),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".fileconverter/converters.yaml"),
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("FileConverter/converters.yaml")
        ].compactMap { $0 }

        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path.path) {
                return try await loadConverters(from: path)
            }
        }

        throw ConfigLoaderError.fileNotFound(path: "converters.yaml (searched in bundle, current dir, /usr/local/etc, ~/.fileconverter, ~/Library/Application Support)")
    }

    public func loadUserConverters() async throws -> [Converter] {
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let userConfigURL = appSupportURL
            .appendingPathComponent("FileConverter")
            .appendingPathComponent("converters.yaml")

        if FileManager.default.fileExists(atPath: userConfigURL.path) {
            return try await loadConverters(from: userConfigURL)
        } else {
            return try await loadDefaultConverters()
        }
    }
}

// Simple YAML decoder (basic implementation)
class YAMLDecoder {
    func decode(_ type: [String: Any].Type, from yaml: String) throws -> [String: Any] {
        // For speed, parsing YAML manually for this simple format
        var result: [String: Any] = [:]
        var converters: [[String: Any]] = []

        let lines = yaml.split(separator: "\n", omittingEmptySubsequences: false)
        var currentConverter: [String: Any]?
        var currentOptions: [[String: Any]] = []

        for line in lines {
            let trimmed = String(line).trimmingCharacters(in: .whitespaces)

            if trimmed.starts(with: "version:") {
                let value = trimmed.replacingOccurrences(of: "version:", with: "").trimmingCharacters(in: .whitespaces)
                result["version"] = value.replacingOccurrences(of: "\"", with: "")
            } else if trimmed == "- id:" || (trimmed.starts(with: "- id:") && currentConverter != nil) {
                if var converter = currentConverter {
                    converter["options"] = currentOptions
                    converters.append(converter)
                }
                currentConverter = [:]
                currentOptions = []
            } else if trimmed.starts(with: "id:"), var converter = currentConverter {
                let value = trimmed.replacingOccurrences(of: "id:", with: "").trimmingCharacters(in: .whitespaces)
                converter["id"] = value.replacingOccurrences(of: "\"", with: "")
                currentConverter = converter
            }
            // Simplified - full YAML parsing would be more comprehensive
        }

        if var converter = currentConverter {
            converter["options"] = currentOptions
            converters.append(converter)
        }

        result["converters"] = converters
        return result
    }
}
