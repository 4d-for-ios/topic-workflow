import Foundation
import FileKit
import SwiftyJSON

public struct Topic {
    var name: String
}

extension Topic {

    public func jsonItems(at workingPath: Path) throws -> JSON {
        let path: Path = workingPath + "\(name).json"
        let content = try TextFile(path: path).read()
        let json = JSON(parseJSON: content)
        // XXX if incomplete, get pagination files?
        return json
    }

    static func readTopics(_ workingPath: Path) throws -> [Topic] {
        let topicsPath: Path = workingPath + "topics.txt"
        let topicsContent = try TextFile(path: topicsPath).read()
        return topicsContent
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { Topic(name: $0) }
    }
}
