import FileKit
import SwiftyJSON
import Result
import Foundation
import Commandant

struct GenerateCommand: CommandProtocol {
    typealias Options = GenerateOptions
    typealias ClientError = Options.ClientError

    let verb: String = "generate"
    var function: String = "generate files by repository"

    func run(_ options: GenerateCommand.Options) -> Result<(), GenerateCommand.ClientError> {
        let workDirectoryString = options.path ?? FileManager.default.currentDirectoryPath
        let workDirectory = URL(fileURLWithPath: workDirectoryString)
        guard FileManager.default.isDirectory(workDirectory.path) else {
            fatalError("\(workDirectoryString) is not directory.")
        }

        //let config = Config(options: options) ?? Config.default
        let builder = Generate()
        do {
            try builder.run(Path(rawValue: workDirectoryString))
        } catch let error as FileKitError {
            print("\(error) \(String(describing: error.error))")
            exit(1)
        } catch {
            print("\(error)")
            exit(2)
        }

        return .success(())
    }
}

struct GenerateOptions: OptionsProtocol {
    typealias ClientError = CommandantError<()>

    let path: String?
    let email: String?
    let configurationFile: String?

    static func create(_ path: String?) -> (_ email: String?) -> (_ config: String?) -> GenerateOptions {
        return { email in
            return { config in
                self.init(path: path, email: email, configurationFile: config)
            }
        }
    }

    static func evaluate(_ mode: CommandMode) -> Result<GenerateCommand.Options, CommandantError<GenerateOptions.ClientError>> {
        return create
            <*> mode <| Option(key: "path", defaultValue: nil, usage: "project root directory")
            <*> mode <| Option(key: "email", defaultValue: nil, usage: "email to send new")
            <*> mode <| Option(key: "config", defaultValue: nil, usage: "the path to configuration file")
    }
}

extension Config {
    init?(options: GenerateOptions) {
        if let configurationFile = options.configurationFile {
            let configurationURL = URL(fileURLWithPath: configurationFile)
            try? self.init(url: configurationURL)
        } else {
            let workDirectoryString = options.path ?? FileManager.default.currentDirectoryPath
            let workDirectory = URL(fileURLWithPath: workDirectoryString)
            try? self.init(directoryURL: workDirectory)
        }
    }
}

public class Generate {
    public func run(_ workingPath: Path) throws {
        let topics = try Topic.readTopics(workingPath)

        for topic in topics {
            print("🏷 \(topic.name)")
            let json = try topic.jsonItems(at: workingPath)
            print("⏲ \(json["total_count"])")
            let news: [JSON] = []
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
                        news.append(itemJson)
                    }
                    try DataFile(path: topicPath).write(itemJson.rawData())
                }
            }
            if !news.isEmpty {
                print("🎉 There is new packages")
            }
        }
    }

}
