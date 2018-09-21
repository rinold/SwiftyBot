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
}

extension ReplyKeyboardMarkup {
    public init() {
        keyboard = []
    }
}

public struct KeyboardButton: Codable {
    var text: String
}
