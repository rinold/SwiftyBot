//
//  Location.swift
//  Engine
//
//  Created by Mikhail Churbanov on 23/09/2018.
//

import FluentSQLite

public final class Location: Codable {
    /// Database id
    public var id: Int?
    /// Name of location
    public var name: String
    /// Location description
    public var description: String

    public init(id: Int?, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
}

extension Location {
    static let nowhere = Location(id: nil, name: "Nowhere", description: "")
}

extension Location: SQLiteModel { }
