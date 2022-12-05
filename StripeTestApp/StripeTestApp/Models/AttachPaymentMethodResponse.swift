//
//  AttachPaymentMethodResponse.swift
//  StripeTestApp
//
//  Created by Serhii on 05.12.2022.
//

import Foundation

struct AttachPaymentMethodResponse: Decodable {
    let customerId: String
    let paymentMethodId: String
    let creditCard: CreditCard
    
    enum CodingKeys: String, CodingKey {
        case customer
        case id
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        customerId = try values.decode(String.self, forKey: .customer)
        paymentMethodId = try values.decode(String.self, forKey: .id)
        creditCard = try CreditCard(from: decoder)
    }
}
