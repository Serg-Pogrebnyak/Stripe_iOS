//
//  PaymentIntentsResponse.swift
//  StripeTestApp
//
//  Created by Serhii on 30.11.2022.
//

import Foundation

struct PaymentIntentsResponse: Decodable {
    let paymentIntents: [PaymentIntent]
    let pagination: PaymentIntentPaginationType
    
    enum CodingKeys: String, CodingKey {
        case data
        case has_more
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let canLoadMore = try values.decode(Bool.self, forKey: .has_more)
        paymentIntents = try values.decode([PaymentIntent].self, forKey: .data)
        pagination = PaymentIntentPagination(lastLoadedId: paymentIntents.last?.id,
                                             canLoadMore: canLoadMore)
    }
}
