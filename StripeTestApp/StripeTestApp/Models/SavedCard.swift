//
//  SavedCard.swift
//  StripeTestApp
//
//  Created by Serhii on 25.11.2022.
//

import Foundation

struct SavedCard: Decodable {
    let id: String
    let brand: String
    let expMonth: Int
    let expYear: Int
    let last4: String
    
    var description: String { "\(brand) \(expMonth)/\(expYear) \(last4)" }
    
    enum CodingKeys: String, CodingKey {
        case id
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
        id = try paymentMethodContainer.decode(String.self, forKey: .id)
        let ccContainer = try paymentMethodContainer.nestedContainer(keyedBy: CodingKeys.CardCodingKeys.self,
                                                                     forKey: .card)
        brand = try ccContainer.decode(String.self, forKey: CodingKeys.CardCodingKeys.brand)
        expMonth = try ccContainer.decode(Int.self, forKey: CodingKeys.CardCodingKeys.exp_month)
        expYear = try ccContainer.decode(Int.self, forKey: CodingKeys.CardCodingKeys.exp_year)
        last4 = try ccContainer.decode(String.self, forKey: CodingKeys.CardCodingKeys.last4)
    }
}
