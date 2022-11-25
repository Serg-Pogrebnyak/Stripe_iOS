//
//  SavedCard.swift
//  StripeTestApp
//
//  Created by Serhii on 25.11.2022.
//

import Foundation

struct SavedCard: Decodable {
    let brand: String
    let expMonth: Int
    let expYear: Int
    let last4: String
    
    enum CodingKeys: String, CodingKey {
        case card
        
        enum CardCodingKeys: String, CodingKey {
            case brand
            case exp_month
            case exp_year
            case last4
        }
    }
    
    init(from decoder: Decoder) throws {
        let paymentMethodContainer = try decoder.container(keyedBy: CodingKeys.self)
        let ccContainer = try paymentMethodContainer.nestedContainer(keyedBy: CodingKeys.CardCodingKeys.self,
                                                                     forKey: .card)
        brand = try ccContainer.decode(String.self, forKey: CodingKeys.CardCodingKeys.brand)
        expMonth = try ccContainer.decode(Int.self, forKey: CodingKeys.CardCodingKeys.exp_month)
        expYear = try ccContainer.decode(Int.self, forKey: CodingKeys.CardCodingKeys.exp_year)
        last4 = try ccContainer.decode(String.self, forKey: CodingKeys.CardCodingKeys.last4)
    }
}
