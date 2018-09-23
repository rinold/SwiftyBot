//
//  Move.swift
//  Telegram
//
//  Created by Mikhail Churbanov on 23/09/2018.
//

public final class MoveCommandProcessor: Processor {
    public let commands = ["Данж"]
    /// For start command the parameters string is referal link if present
    public func process(_ player: Player, command: String, with parameters: String?) -> Telegram.Response? {
        let message = Telegram.Response.respond(to: player.chatId, text: "Delayed event!")
        try! Engine.respondAfter(time: 30, with: message)
        return .respond(to: player.chatId, text: "Ты пошел, жди...")
    }
}
