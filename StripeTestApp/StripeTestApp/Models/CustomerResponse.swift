//
//  CustomerResponse.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import Foundation

struct CustomerResponse: Decodable {
    let customers: [Customer]
    let pagination: PaginationType
    
    enum CodingKeys: String, CodingKey {
        case data
        case has_more
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let canLoadMore = try values.decode(Bool.self, forKey: .has_more)
        customers = try values.decode([Customer].self, forKey: .data)
        pagination = Pagination(lastLoadedId: customers.last?.id,
                                canLoadMore: canLoadMore)
    }
}
