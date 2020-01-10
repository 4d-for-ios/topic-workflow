//
//  File.swift
//  
//
//  Created by Eric Marchand on 10/01/2020.
//

import Foundation
import FileKit

struct FileTextReporter: Reporter {

    static let identifier = "filetext"

    static func generateReport(topic: Topic, at workingPath: Path) throws -> String {

        var string = ""
        let repositories = try topic.repositories(at: workingPath).items
        for item in repositories.sorted(by: { $0.full_name < $1.full_name }) {
            string += "\(item.html_url)\n"
        }
        try TextFile(path: workingPath + "\(topic.name).txt").write(string)

        return string
    }
}
