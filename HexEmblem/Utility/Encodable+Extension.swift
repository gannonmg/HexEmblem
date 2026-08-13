//
//  Encodable+Extension.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/12/26.
//

import Foundation

extension Encodable {
    func debugPrint() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Key step for formatting

        do {
            let data = try encoder.encode(self)
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("❌ Failed to pretty print Codable object: \(error)")
        }
    }
}
