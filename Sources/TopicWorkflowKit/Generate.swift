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
    public func run(_ workingPath: Path, apiKey: String?, email: String?, domain: String?) throws {
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
                        if let data = itemJson.dictionaryObject {
                            news.append(data)
                        }
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
            if let apiKey = apiKey, let domain = domain {
                let mailgun = Mailgun(apiKey: apiKey, domain: domain, region: .us)
                let message = Mailgun.TemplateMessage(
                    from: "eric.marchand@4d.com",
                    to: email ?? "eric.marchand@4d.com",
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
            }
        }
    }

}
