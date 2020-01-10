//
//  DOTReporter.swift
//  TopicWorkflowKit
//
//  Created by eric.marchand on 09/01/2020.
//

import Foundation
import FileKit

struct MarkdownReporter: Reporter {

    static let identifier = "markdown"

    static func generateReport(topic: Topic, at workingPath: Path) throws -> String {
        var string = "## \(topic.name)\n\n"
        string += "| Repository | Workflow | Download |\n"
        string += "| ---------- | -------- | -------- |\n"

        let repositories = try topic.repositories(at: workingPath).items
        for item in repositories.sorted(by: { $0.full_name < $1.full_name }) {
            string += "|[\(item.full_name)](\(item.html_url)) |"
            string += "[![\(item.name)](\(item.html_url)/workflows/check/badge.svg)](\(item.html_url)/actions?workflow=check) |"
            string += "[![release](https://img.shields.io/github/v/release/\(item.full_name))](\(item.html_url)/releases/latest/download/\(item.name).zip)|\n"
        }
        return string
    }
}
