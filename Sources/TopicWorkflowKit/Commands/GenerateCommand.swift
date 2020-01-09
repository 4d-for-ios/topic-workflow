import FileKit
import SwiftyJSON
import Result
import Foundation
import Commandant
import Mailgun
import Vapor
import Service

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
            try builder.run(Path(rawValue: workDirectoryString), apiKey: options.apiKey, email: options.email)
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
    let apiKey: String?
    let configurationFile: String?

    static func create(_ path: String?) -> (_ email: String?)  -> (_ apiKey: String?) -> (_ config: String?) -> GenerateOptions {
        return { email in
            return { apiKey in
                return { config in
                    self.init(path: path, email: email, apiKey: apiKey, configurationFile: config)
                }
            }
        }
    }

    static func evaluate(_ mode: CommandMode) -> Result<GenerateCommand.Options, CommandantError<GenerateOptions.ClientError>> {
        return create
            <*> mode <| Option(key: "path", defaultValue: nil, usage: "project root directory")
            <*> mode <| Option(key: "email", defaultValue: nil, usage: "email to send new")
            <*> mode <| Option(key: "apiKey", defaultValue: nil, usage: "apiKey to send mail using mailgun")
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
    public func run(_ workingPath: Path, apiKey: String?, email: String?) throws {
        let topics = try Topic.readTopics(workingPath)

        var news: [[String: Any]] = []
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
                        if let data = itemJson.dictionaryObject {
                            news.append(data)
                        }
                    }
                    try DataFile(path: topicPath).write(itemJson.rawData())
                }
            }
        }

        if !news.isEmpty {
             print("🎉 There is new packages")

            if let apiKey = apiKey {
                /*   let domain = "sandbox01fc72c22b9a484eb7ffebbb1d590b73.mailgun.org"
                 let mailgun = Mailgun(apiKey: apiKey, domain: domain, region: .eu)
                 let message = Mailgun.TemplateMessage(
                 from: "eric.marchand@4d.com",
                 to: email ?? "eric.marchand@4d.com",
                 subject: "News 4d-for-ios repositories",
                 template: "new-repository",
                 templateData: ["repositories": ""]
                 )
                 let app = try Application()
                 let future = try mailgun.send(message, on: app)
                 let semaphore = DispatchSemaphore(value: 0)
                 future.whenSuccess { value in
                 print("send email success")
                 }
                 future.whenFailure { error in
                 print("\(error)")
                 }
                 future.whenComplete {
                 semaphore.signal()
                 }
                 semaphore.wait()*/
            }
        }
    }

}
