//
//  Processor.swift
//  Engine
//
//  Created by Mikhail Churbanov on 23/09/2018.
//

public protocol Processor {
    var commands: [String] { get }
    func canProcess(command: String) -> Bool
    func process(_ player: Player, command: String, with parameters: String?) -> Telegram.Response?
}

extension Processor {
    public func canProcess(command: String) -> Bool {
        return self.commands.contains(command)
    }
}
