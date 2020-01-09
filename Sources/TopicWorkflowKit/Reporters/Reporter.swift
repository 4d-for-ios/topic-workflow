//
//  Reporter.swift
//  TopicWorkflowKit
//
//  Created by eric.marchand on 09/01/2020.
//
import FileKit

public protocol Reporter {
    static var identifier: String { get }

    static func generateReport(topic: Topic, at workingPath: Path) throws -> String
}

public struct Reporters {

    public static func reporter(from reporter: String) -> Reporter.Type {
        switch reporter {
        case DefaultReporter.identifier:
            return DefaultReporter.self
        case MarkdownReporter.identifier:
            return MarkdownReporter.self
        default:
            fatalError("no reporter with identifier '\(reporter) available'")
        }
    }
}
