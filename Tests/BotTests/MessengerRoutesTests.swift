//
//  MessengerRoutesTests.swift
//  SwiftyBot
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 - 2018 Fabrizio Brancati.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
@testable import Messenger
import Vapor
import XCTest

/// Messenger Routes Tests.
internal class MessengerRoutesTests: XCTestCase {
    // swiftlint:disable implicitly_unwrapped_optional
    internal var bot: Application!
    // swiftlint:enable implicitly_unwrapped_optional
    
    internal override func setUp() {
        super.setUp()
        
        do {
            bot = try Application.testable()
        } catch {}
    }
    
    internal func testRouteInGetWithActivation() throws {
        let activation = Activation(mode: "subscribe", token: messengerToken, challenge: "Test Challenge")
        let response = try bot.getResponse(to: "messenger/\(messengerSecret)", method: .GET, headers: ["Content-Type": "application/json"], data: activation, decodeTo: String.self)

        XCTAssertEqual(response, "Test Challenge")
    }
    
    internal func testRouteInGetWithWrongActivation() throws {
        let activation = Activation(mode: "Test", token: messengerToken, challenge: "Test Challenge")
        let response = try bot.getResponse(to: "messenger/\(messengerSecret)", method: .GET, headers: ["Content-Type": "application/json"], data: activation, decodeTo: String.self)
        
        XCTAssertEqual(response, "{\"error\":true,\"reason\":\"Missing Messenger verification data.\"}")
    }
}
