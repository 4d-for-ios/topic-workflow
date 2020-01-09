import FileKit
import SwiftyJSON
import Result
import Foundation
import Commandant

struct ListCommand: CommandProtocol {
    typealias Options = ListOptions
    typealias ClientError = Options.ClientError

    let verb: String = "list"
    var function: String = "list repositories"

    func run(_ options: ListCommand.Options) -> Result<(), ListCommand.ClientError> {
        let workDirectoryString = options.path ?? FileManager.default.currentDirectoryPath
        let workDirectory = URL(fileURLWithPath: workDirectoryString)
        guard FileManager.default.isDirectory(workDirectory.path) else {
            fatalError("\(workDirectoryString) is not directory.")
        }

        let config = Config(options: options) ?? Config.default
        let builder = List()
        do {
            let reporter = Reporters.reporter(from: options.reporter ?? config.reporter)
            try builder.run(at: Path(rawValue: workDirectoryString), reporter: reporter)
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

struct ListOptions: OptionsProtocol {
    typealias ClientError = CommandantError<()>

    let path: String?
    let reporter: String?
    let configurationFile: String?

    static func create(_ path: String?) -> (_ reporter: String?) -> (_ config: String?) -> ListOptions {
        return { reporter in
            return { config in
                self.init(path: path, reporter: reporter, configurationFile: config)
            }
        }
    }

    static func evaluate(_ mode: CommandMode) -> Result<ListCommand.Options, CommandantError<ListOptions.ClientError>> {
        return create
            <*> mode <| Option(key: "path", defaultValue: nil, usage: "project root directory")
            <*> mode <| Option(key: "reporter", defaultValue: nil, usage: "reporter")
            <*> mode <| Option(key: "config", defaultValue: nil, usage: "the path to configuration file")
    }
}

extension Config {
    init?(options: ListOptions) {
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

public class List {
    public func run(at workingPath: Path, reporter: Reporter.Type) throws {
        let topics = try Topic.readTopics(workingPath)
        for topic in topics {
            let topicReport = try reporter.generateReport(topic: topic, at: workingPath)
            print(topicReport)
        }
    }
}
