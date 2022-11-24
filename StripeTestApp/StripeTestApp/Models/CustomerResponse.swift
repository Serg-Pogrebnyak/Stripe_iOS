//
//  CustomerResponse.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import Foundation

struct CustomerResponse: Decodable {
    let customers: [Customer]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        customers = try values.decode([Customer].self, forKey: .data)
    }
}
