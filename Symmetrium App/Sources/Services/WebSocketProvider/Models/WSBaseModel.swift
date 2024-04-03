//
//  WSBaseModel.swift
//  SymmetriumDemoProj
//
//  Created by Sergiy Brotsky on 03.04.2024.
//  Copyright © 2024 Stas Seldin. All rights reserved.
//

import Foundation

// MARK: - WSBaseEvent
enum WSBaseEvent: String, Codable {
    case message
    case touch
}

// MARK: - WSBaseModel
struct WSBaseModel: Codable {
    let type: WSBaseEvent
    let body: Data?
}

// MARK: - WSBaseModel encoder and decoder
extension WSBaseModel {
    
    // get data from data channel
    init?(from data: Data) throws {
        
        let decodedModel = try JSONDecoder().decode(WSBaseModel.self, from: data)
        
        self.type = decodedModel.type
        self.body = decodedModel.body
        
    }
    
    // parse body
    func parse<T: Decodable>(_ type: T.Type, by decoder: JSONDecoder) throws -> T? {
        
        if let body {
            return try decoder.decode(type, from: body)
        }
        
        throw WSErrors.failedToDecode
    }
    
    // encode body and all WSBaseModel
    static func data<T: Encodable>(type: WSBaseEvent, _ data: T) throws -> Data {
        let jsonData = try JSONEncoder().encode(data)
        
        let model = WSBaseModel(type: type, body: jsonData)
        
        return try JSONEncoder().encode(model)
    }
    
}
