//
//  DefaultReporter.swift
//  TopicWorkflowKit
//
//  Created by eric.marchand on 09/01/2020.
//

import Foundation
import FileKit

struct DefaultReporter: Reporter {

    static let identifier = "default"

    static func generateReport(topic: Topic, at workingPath: Path) throws -> String {
        var string = "🏷  \(topic.name)\n"

        let repositories = try topic.repositories(at: workingPath).items
        for item in repositories {
            string += "📦 \(item.full_name)\n"
        }
        return string
    }
}
