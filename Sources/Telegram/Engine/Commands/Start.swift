//
//  File.swift
//  Engine
//
//  Created by Mikhail Churbanov on 22/09/2018.
//

public final class StartCommandProcessor: Processor {
    public let commands = ["start"]
    /// For start command the parameters string is referal link if present
    public func process(_ player: Player, command: String, with parameters: String?) -> Telegram.Response? {
        return .respond(to: player.chatId, text: "Приветствую тебя, \(player.name)!")
    }
    
    public init() { }
}
