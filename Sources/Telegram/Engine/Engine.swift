//
//  Engine.swift
//  Engine
//
//  Created by Mikhail Churbanov on 22/09/2018.
//

import Vapor
import Fluent

extension Telegram.Response {
    static public func respond(to chatId: Int, text: String) -> Telegram.Response {
        var keyboardMarkup = ReplyKeyboardMarkup()
        let row = [KeyboardButton(text: "Персонаж"), KeyboardButton(text: "Данж")]
        keyboardMarkup.keyboard.append(row)

        return Telegram.Response(method: .sendMessage,
                                 chatID: chatId,
                                 text: text,
                                 replyMarkup: keyboardMarkup,
                                 parseMode: .markdown)
    }
}

public final class Engine {

    static private var engine = Engine()

    var botClient: BotClient
    var commandProcessors: [Processor] = []
    var longTasksQueue = DispatchQueue(label: "thyearbot.engine.longTasksQueue",
                                       qos: .utility,
                                       attributes: .concurrent)

    private init() {
        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        botClient = try! BotClient(host: "api.telegram.org", port: 80, token: telegramSecret, worker: worker)
    }

    static public func register(processors: [Processor]) {
        engine.commandProcessors = processors
    }

    static public func process(request: Request) throws -> Telegram.Response {
        let message = try request.content.syncDecode(MessageRequest.self).message
        let player = try getPlayer(from: message, on: request)

        var command = ""
        var parameters: String?
        if let telegramCommand = Command(message.text) {
            command = telegramCommand.command
            parameters = telegramCommand.parameters
        } else {
            command = message.text
        }

        for processor in engine.commandProcessors {
            guard processor.canProcess(command: command) else {
                continue
            }
            if let response = processor.process(player, command: command, with: parameters) {
                return response
            }
        }

        return .respond(to: message.chat.id, text: "Empty 😢")
    }

    static public func respondAfter(time: TimeInterval, with response: Telegram.Response) throws {
        let body = HTTPBody(data: try JSONEncoder().encode(response))
        let headers = HTTPHeaders([("Content-Type", "application/json")])
        let deadlineTime = DispatchTime.now() + time
        engine.longTasksQueue.asyncAfter(deadline: deadlineTime) {
            try? engine.botClient.respond(endpoint: "sendMessage",
                                          body: body,
                                          headers: headers).map(to: TelegramContainer<Message>.self) { container in
                return container
            }
        }
    }

}

extension Engine {
    static public func getPlayer(from message: Message, on request: Request) throws -> Player {
        if let player = try Player.query(on: request).filter(\.telId == message.from.id).first().wait() {
            return player
        }
        return Player(telId: message.from.id, chatId: message.chat.id, name: message.from.firstName)
    }
}
