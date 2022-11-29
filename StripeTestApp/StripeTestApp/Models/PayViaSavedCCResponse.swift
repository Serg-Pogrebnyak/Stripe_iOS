//
//  PayViaSavedCCResponse.swift
//  StripeTestApp
//
//  Created by Serhii on 29.11.2022.
//

import Foundation

struct PayViaSavedCCResponse: Decodable {
    let amount: Float
    let currency: String
    let customerId: String
    let status: String
    
    var description: String {
        R.string.localizable.paymentSucceededWithStatus() + status + "\n" +
        R.string.localizable.orderAmount() + amount.description + currency + "\n" +
        R.string.localizable.customerId() + customerId
    }
    
    enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case customer
        case status
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let amountInCents = try values.decode(Int.self, forKey: .amount)
        amount = AmountConverter.centsToAmount(amountInCents)
        currency = try values.decode(String.self, forKey: .currency)
        customerId = try values.decode(String.self, forKey: .customer)
        status = try values.decode(String.self, forKey: .status)
    }
}
