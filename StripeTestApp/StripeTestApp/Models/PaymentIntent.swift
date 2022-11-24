//
//  PaymentIntent.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import Foundation

struct PaymentIntent: Decodable {
    let id: String
    let amount: Int
    let currency: String
    let secret: String
    let customerId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case currency
        case client_secret
        case customer
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        amount = try values.decode(Int.self, forKey: .amount)
        currency = try values.decode(String.self, forKey: .currency)
        secret = try values.decode(String.self, forKey: .client_secret)
        customerId = try values.decode(String.self, forKey: .customer)
    }
}
