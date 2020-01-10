//
//  File.swift
//  
//
//  Created by Eric Marchand on 09/01/2020.
//

import Foundation
import FileKit
import SwiftyJSON
import Result
import Commandant
import Mailgun
import Vapor
import AnyCodable

public class Generate {
    public func run(_ workingPath: Path, mailParameters: MailParameters?) throws {
        let topics = try Topic.readTopics(workingPath)

        var news: [[String: String]] = []
        for topic in topics {
            print("🏷 \(topic.name)")
            let json = try topic.jsonItems(at: workingPath)
            print("⏲ \(json["total_count"])")
            for itemJson in json["items"].arrayValue {
                if let fullName = itemJson["full_name"].string {
                    print(" 📦 \(fullName)", terminator: "")
                    let outputPath: Path = workingPath + "Output"
                    let topicParentPath: Path = outputPath + topic.name
                    let topicPath: Path = topicParentPath + "\(fullName).json"
                    if topicPath.exists {
                        print(" 👴 EXISTS") // could check updated?
                    } else {
                        let orgaPath = topicPath.parent
                        if !orgaPath.exists {
                            try orgaPath.createDirectory()
                        }
                        print(" 👶 NEW")
                        if let data = itemJson.repository?.dico  {
                            news.append(data)
                        }
                    }
                    try DataFile(path: topicPath).write(itemJson.rawData())
                }
            }
        }
        if !news.isEmpty {
            print("🎉 There is new packages")
            if let mailParameters = mailParameters {
                print("💌 Send an email to \(mailParameters.to)")
                let mailgun = Mailgun(apiKey: mailParameters.apiKey, domain: mailParameters.domain, region: .us)
                let message = Mailgun.TemplateMessage(
                    from: mailParameters.from,
                    to: mailParameters.to,
                    subject: "News 4d-for-ios repositories",
                    template: "new-repository",
                    templateData: ["repositories": AnyCodable(news)]
                )
                let app = try Application()
                let future = try mailgun.send(message, on: app)
                let semaphore = DispatchSemaphore(value: 0)
                future.whenSuccess { value in
                    print("\(value)")
                }
                future.whenFailure { error in
                    print("\(error)")
                }
                future.whenComplete {
                    semaphore.signal()
                }
                semaphore.wait()
            } // else no mail
        }
    }

}

public struct MailParameters {

    var apiKey: String
    var from: String
    var to: String
    var domain: String

    static func create(apiKey: String?,
                       from: String?,
                       to: String?,
                       domain: String?)  -> MailParameters? {
        guard let apiKey = apiKey, let domain = domain, let to = to, let from = from else {
            return nil
        }
        return MailParameters(apiKey: apiKey, from: from, to: to, domain: domain)
    }

}
