import Foundation

struct Converter: Decodable, Identifiable {
    let id: String
    let name: String
    let category: String
    let inputFormats: [String]
    let outputFormats: [String]
    let tool: String
    let command: String
    let options: [ConverterOption]
}

struct ConverterOption: Decodable, Identifiable {
    let id: UUID = UUID()
    let name: String
    let type: OptionType
    let values: [String]?
    let min: Int?
    let max: Int?
    let `default`: String

    enum OptionType: String, Decodable {
        case select
        case slider
    }

    private enum CodingKeys: String, CodingKey {
        case name, type, values, min, max
        case `default` = "default"
    }
}

enum ConversionJobState: Equatable {
    case queued
    case inProgress(progress: Double)
    case succeeded
    case failed(error: String)
    case cancelled
}

struct ConversionJob: Identifiable {
    let id: UUID
    let inputURL: URL
    let converter: Converter
    var selectedOptions: [String: String] = [:]
    var state: ConversionJobState = .queued
    var outputURL: URL?
    var createdAt: Date = Date()
}
