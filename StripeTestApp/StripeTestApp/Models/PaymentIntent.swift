//
//  PaymentIntent.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import Foundation

struct PaymentIntent: Decodable {
    let id: String
    let amount: Float
    let currency: String
    let secret: String
    let customerId: String
    let status: String
    
    var description: String {
        R.string.localizable.paymentSucceededWithStatus() + status + "\n" +
        R.string.localizable.orderAmount() + amount.description + currency + "\n" +
        R.string.localizable.customerId() + customerId
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case currency
        case client_secret
        case customer
        case status
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let amountInCents = try values.decode(Int.self, forKey: .amount)
        id = try values.decode(String.self, forKey: .id)
        amount = AmountConverter.centsToAmount(amountInCents)
        currency = try values.decode(String.self, forKey: .currency)
        secret = try values.decode(String.self, forKey: .client_secret)
        customerId = try values.decode(String.self, forKey: .customer)
        status = try values.decode(String.self, forKey: .status)
    }
}
