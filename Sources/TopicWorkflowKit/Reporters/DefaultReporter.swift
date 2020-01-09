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

        let json = try topic.jsonItems(at: workingPath)
        for item in json["items"].arrayValue {
            if let fullName = item["full_name"].string {
                string += "📦 \(fullName)\n"
            }
        }
        return string
    }
}
