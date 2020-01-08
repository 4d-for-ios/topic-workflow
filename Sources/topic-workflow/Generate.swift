import FileKit
import SwiftyJSON

public class Generate {
    public static func run(_ workingPath: Path) throws {
        let topics = try readTopics(workingPath)

        for topic in topics {
            print("🏷 \(topic.name)")
            let json = try topic.jsonItems(at: workingPath)
            print("⏲ \(json["total_count"])")

            for itemJson in json["items"].arrayValue {
                if let fullName = itemJson["full_name"].string {
                    print(" 📦 \(fullName)")
                    let outputPath: Path = workingPath + "Output"
                    let topicParentPath: Path = outputPath + topic.name
                    let topicPath: Path = topicParentPath + "\(fullName).json"
                    if topicPath.exists {
                        print("  👴 EXISTS") // could check updated?
                    } else {
                        let orgaPath = topicPath.parent
                        if !orgaPath.exists {
                            try orgaPath.createDirectory()
                        }
                        print("  👶 NEW")
                    }
                    try DataFile(path: topicPath).write(itemJson.rawData())
                }
            }
        }
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
