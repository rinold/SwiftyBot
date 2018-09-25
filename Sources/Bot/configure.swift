//
//  configure.swift
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

import Telegram
import Vapor
import FluentPostgreSQL

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router.
    let router = EngineRouter.default()
    
    /// Add the Telegram routes.
    try Telegram.routes(router)
    /// Register all the routes.
    services.register(router, as: Router.self)

    Engine.register(processors: [
        StartCommandProcessor(),
        MoveCommandProcessor()
    ])

    /// Register middleware.
    /// Create _empty_ middleware config.
    var middlewares = MiddlewareConfig()
    /// Catches errors and converts to HTTP response.
    middlewares.use(ErrorMiddleware.self)
    /// Register middlewares to services.
    services.register(middlewares)

    // Configure a SQLite database
//    let sqlite = try SQLiteDatabase(storage: .memory)
    
    let dbConfig = PostgreSQLDatabaseConfig(hostname: Environment.get("DATABASE_HOSTNAME") ?? "",
                                            port: 5432,
                                            username: Environment.get("DATABASE_USER") ?? "",
                                            database: Environment.get("DATABASE_DB"),
                                            password: Environment.get("DATABASE_PASSWORD"))

    let db = PostgreSQLDatabase(config: dbConfig)

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: db, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Player.self, database: .psql)
    migrations.add(model: Location.self, database: .psql)
    services.register(migrations)
}
