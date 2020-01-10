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
            try builder.run(Path(rawValue: workDirectoryString), mailParameters: options.mailParameters)
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
    let to: String?
    let from: String?
    let apiKey: String?
    let domain: String?
    let configurationFile: String?

    static func create(_ path: String?) -> (_ to: String?) -> (_ from: String?) -> (_ apiKey: String?) -> (_ domain: String?) -> (_ config: String?) -> GenerateOptions {
        return { to in
            return { from in
                return { apiKey in
                    return { domain in
                        return { config in
                            self.init(path: path, to: to, from: from, apiKey: apiKey, domain: domain, configurationFile: config)
                        }
                    }
                }
            }
        }
    }

    static func evaluate(_ mode: CommandMode) -> Result<GenerateCommand.Options, CommandantError<GenerateOptions.ClientError>> {
        return create
            <*> mode <| Option(key: "path", defaultValue: nil, usage: "project root directory")
            <*> mode <| Option(key: "to", defaultValue: nil, usage: "email to send new repo")
            <*> mode <| Option(key: "from", defaultValue: nil, usage: "email to send with")
            <*> mode <| Option(key: "apiKey", defaultValue: nil, usage: "apiKey to send mail using mailgun")
            <*> mode <| Option(key: "domain", defaultValue: nil, usage: "domain from the mail is send")
            <*> mode <| Option(key: "config", defaultValue: nil, usage: "the path to configuration file")
    }
}

extension GenerateOptions {

    var mailParameters: MailParameters? {
        return MailParameters.create(apiKey: apiKey, from: from, to: to, domain: domain)
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
