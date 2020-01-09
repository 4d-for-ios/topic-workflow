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

        let json = try topic.jsonItems(at: workingPath)
        for item in json["items"].arrayValue.sorted(by: { $0["full_name"].stringValue < $1["full_name"].stringValue }) {
            if let fullName = item["full_name"].string {
                let htmlUrl = item["html_url"].stringValue
                let name = item["name"].stringValue
                string += "|[\(fullName)](\(htmlUrl)) |"
                string += "[![\(name)](\(htmlUrl)/workflows/check/badge.svg)](\(htmlUrl)/actions?workflow=check) |"
                string += "[![release](https://img.shields.io/github/v/release/\(fullName))](\(htmlUrl)/releases/latest/download/\(name).zip)|\n"
            }
        }
        return string
    }
}
