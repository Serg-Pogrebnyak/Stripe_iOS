//
//  PaymentMethodsResponse.swift
//  StripeTestApp
//
//  Created by Serhii on 25.11.2022.
//

import Foundation

struct PaymentMethodsResponse: Decodable {
    let creditCards: [CreditCard]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        creditCards = try values.decode([CreditCard].self, forKey: .data)
    }
}
