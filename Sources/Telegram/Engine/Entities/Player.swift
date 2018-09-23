//
//  File.swift
//  Engine
//
//  Created by Mikhail Churbanov on 22/09/2018.
//

import FluentSQLite

public final class Player: Codable {
    /// Database id
    public var id: Int?
    /// Telegram user id
    public var telId: Int
    /// Telegram chat id
    public var chatId: Int
    /// Telegram unique referal id
    public var refId: String
    /// Telegram user name
    public var name: String
    /// Current player's location
    public var location: Location

    public var strength: Int
    public var endurance: Int
    public var energy: Int
    public var gold: Int

    public init(telId: Int, chatId: Int, name: String) {
        self.id = nil
        self.telId = telId
        self.chatId = chatId
        self.refId = "" // TODO: generate it
        self.name = name
        self.location = .nowhere
        self.strength = 1
        self.endurance = 1
        self.energy = 5
        self.gold = 0
    }
}

extension Player: SQLiteModel { }
