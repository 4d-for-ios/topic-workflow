//
//  File.swift
//  
//
//  Created by Eric Marchand on 09/01/2020.
//

import Foundation
import Commandant

public struct TopicWorkflow {

    public init() {}

    public func run() {
        let registry = CommandRegistry<CommandantError<()>>()
        registry.register(GenerateCommand())
        registry.register(ListCommand())
        registry.register(HelpCommand(registry: registry))
        registry.register(VersionCommand())

        registry.main(defaultVerb: GenerateCommand().verb) { (error) in
            print(String.init(describing: error))
        }
    }
}
