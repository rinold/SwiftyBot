//
//  ReplyKeyboardMarkup.swift
//  SwiftyBot
//
//  Created by Mikhail Churbanov on 22/09/2018.
//

import Foundation

public struct ReplyKeyboardMarkup: Codable {
    var keyboard: [[KeyboardButton]]
    var resizeKeyboard: Bool?
    var oneTimeKeyboard: Bool?
    var selective: Bool?

    /// Coding keys, used by Codable protocol.
    private enum CodingKeys: String, CodingKey {
        case keyboard
        case resizeKeyboard = "resize_keyboard"
        case oneTimeKeyboard = "one_time_keyboard"
        case selective
    }
}

extension ReplyKeyboardMarkup {
    public init() {
        keyboard = []
        resizeKeyboard = true
    }
}

public struct KeyboardButton: Codable {
    var text: String
}
