//
//  Config.swift
//  TopicWorkflowKit
//
//  Created by eric.marchand on 09/01/2020.
//

import Foundation
import Yams

public struct Config: Codable {
    public let reporter: String

    public static let fileName = ".topic-workflow.yml"
    public static let `default` = Config.init()
    public static let defaultReporter = "default"

    private init() {
        reporter = Config.defaultReporter
    }

    init(reporter: String = Config.defaultReporter) {
        self.reporter = reporter
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reporter = try container.decodeIfPresent(String.self, forKey: .reporter) ?? Config.defaultReporter
    }

    public init(url: URL) throws {
        self = try YAMLDecoder().decode(from: String.init(contentsOf: url))
    }

    public init(directoryURL: URL, fileName: String = fileName) throws {
        let url = directoryURL.appendingPathComponent(fileName)
        try self.init(url: url)
    }
}
