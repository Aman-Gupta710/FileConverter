import Foundation

public struct Converter: Decodable, Identifiable {
    public let id: String
    public let name: String
    public let category: String
    public let inputFormats: [String]
    public let outputFormats: [String]
    public let tool: String
    public let command: String
    public let options: [ConverterOption]

    public init(id: String, name: String, category: String, inputFormats: [String], outputFormats: [String], tool: String, command: String, options: [ConverterOption]) {
        self.id = id
        self.name = name
        self.category = category
        self.inputFormats = inputFormats
        self.outputFormats = outputFormats
        self.tool = tool
        self.command = command
        self.options = options
    }
}

public struct ConverterOption: Decodable, Identifiable {
    public let id: UUID = UUID()
    public let name: String
    public let type: OptionType
    public let values: [String]?
    public let min: Int?
    public let max: Int?
    public let `default`: String

    public enum OptionType: String, Decodable {
        case select
        case slider
    }

    private enum CodingKeys: String, CodingKey {
        case name, type, values, min, max
        case `default` = "default"
    }
}

public enum ConversionJobState: Equatable {
    case queued
    case inProgress(progress: Double)
    case succeeded
    case failed(error: String)
    case cancelled
}

public struct ConversionJob: Identifiable {
    public let id: UUID
    public let inputURL: URL
    public let converter: Converter
    public var selectedOptions: [String: String] = [:]
    public var state: ConversionJobState = .queued
    public var outputURL: URL?
    public var createdAt: Date = Date()

    public init(id: UUID = UUID(), inputURL: URL, converter: Converter, selectedOptions: [String : String] = [:], state: ConversionJobState = .queued, outputURL: URL? = nil, createdAt: Date = Date()) {
        self.id = id
        self.inputURL = inputURL
        self.converter = converter
        self.selectedOptions = selectedOptions
        self.state = state
        self.outputURL = outputURL
        self.createdAt = createdAt
    }
}
