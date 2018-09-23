//
//  BotClient.swift
//  Telegram
//
//  Created by Mikhail Churbanov on 23/09/2018.
//

import Foundation
import HTTP

/**
 Contains information about why a request was unsuccessful.
 SeeAlso Telegram Bot API Reference:
 [ResponseParameters](https://core.telegram.org/bots/api#responseparameters)
 */
public final class ResponseParameters: Codable {

    /// Custom keys for coding/decoding `ResponseParameters` struct
    enum CodingKeys: String, CodingKey {
        case migrateToChatId = "migrate_to_chat_id"
        case retryAfter = "retry_after"
    }

    /// Optional. The group has been migrated to a supergroup with the specified identifier. This number may be greater than 32 bits and some programming languages may have difficulty/silent defects in interpreting it. But it is smaller than 52 bits, so a signed 64 bit integer or double-precision float type are safe for storing this identifier.
    public var migrateToChatId: Int64?

    /// Optional. In case of exceeding flood control, the number of seconds left to wait before the request can be repeated
    public var retryAfter: Int?


    public init (migrateToChatId: Int64? = nil, retryAfter: Int? = nil) {
        self.migrateToChatId = migrateToChatId
        self.retryAfter = retryAfter
    }
}

/// This object represents a Telegram server response container.
public struct TelegramContainer<T: Codable>: Codable {

    enum CodingKeys: String, CodingKey {
        case ok = "ok"
        case result = "result"
        case description = "description"
        case errorCode = "error_code"
        case parameters = "parameters"
    }

    public var ok: Bool
    public var result: T?
    public var description: String?
    public var errorCode: Int?
    public var parameters: ResponseParameters?

    public init (ok: Bool, result: T?, description: String?, errorCode: Int?, parameters: ResponseParameters?) {
        self.ok = ok
        self.result = result
        self.description = description
        self.errorCode = errorCode
        self.parameters = parameters
    }
}

public enum BotClientError: Error {
    case noDataToDecode
}

public class BotClient {

    let host: String
    let port: Int

    let token: String
    var client: HTTPClient?
    let worker: Worker
    let callbackWorker: Worker

    public init(host: String, port: Int, token: String, worker: Worker) throws {
        self.host = host
        self.port = port
        self.token = token
        self.worker = worker
        self.callbackWorker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    /// Sends request to api.telegram.org, and receive TelegramContainer object
    ///
    /// - Parameters:
    ///   - endpoint: Telegram method endpoint
    ///   - body: Body of request (optional)
    ///   - headers: Custom header of request (By default "Content-Type" : "application/json")
    ///   - client: custom client, if not metioned, uses default
    /// - Returns: Container with response
    /// - Throws: Errors
    func respond<T: Codable>(endpoint: String, body: HTTPBody, headers: HTTPHeaders) throws -> Future<TelegramContainer<T>> {
        let url = apiUrl(endpoint: endpoint)
        let httpRequest = HTTPRequest(method: .POST, url: url, headers: headers, body: body)

        let promise = worker.eventLoop.newPromise(TelegramContainer<T>.self)

        worker.eventLoop.execute {
            self.send(request: httpRequest).whenSuccess({ (container) in
                promise.succeed(result: container)
            })
        }
        return promise.futureResult
    }

    private func send<T: Codable>(request: HTTPRequest) -> Future<TelegramContainer<T>> {
        var futureClient: Future<HTTPClient>
        if let existingClient = client {
            futureClient = Future<HTTPClient>.map(on: worker, { existingClient })
        } else {
            futureClient = HTTPClient
                .connect(scheme: .https, hostname: host, port: port, on: worker, onError: { (error) in
                    self.client = nil
                })
                .do({ (freshClient) in
                    self.client = freshClient
                })
        }
        return futureClient
            .catch { (error) in
//                Log.info("HTTP Client was down with error: \n\(error.localizedDescription)")
//                Log.error(error.localizedDescription)
            }
            .then { (client) -> Future<HTTPResponse> in
//                Log.info("Sending request to vapor HTTPClient")
                return client.send(request)
            }
            .map(to: TelegramContainer<T>.self) { (response) -> TelegramContainer<T> in
//                Log.info("Decoding response from HTTPClient")
                return try self.decode(response: response)
        }
    }

    func decode<T: Encodable>(response: HTTPResponse) throws -> TelegramContainer<T> {
        ///Temporary workaround for drop current HTTPClient state after each request,
        ///waiting for fixes from Vapor team
        self.client = nil
        if let data = response.body.data {
            return try JSONDecoder().decode(TelegramContainer<T>.self, from: data)
        }
        throw BotClientError.noDataToDecode
    }

    func apiUrl(endpoint: String) -> URL {
        return URL(string: "https://\(host):\(port)/bot\(token)/\(endpoint)")!
    }
}
