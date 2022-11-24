//
//  Customer.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import Foundation

struct Customer: Decodable {
    let id: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case description
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        description = try values.decode(String.self, forKey: .description)
    }
}
