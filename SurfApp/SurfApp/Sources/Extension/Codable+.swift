//
//  Codable+.swift
//  SurfApp
//
//  Created by 김상현 on 2023/09/17.
//

import Foundation

extension Encodable {

    /// Encode into JSON and return `Data`
    func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
    
}
