//
//  Pagination.swift
//  StripeTestApp
//
//  Created by Serhii on 30.11.2022.
//

import Foundation

protocol PaymentIntentPaginationType {
    var limit: Int { get }
    var canLoadMore: Bool { get }
    var lastLoadedId: String? { get }
}

struct PaymentIntentPagination: PaymentIntentPaginationType {
    let limit = 20
    let lastLoadedId: String?
    let canLoadMore: Bool
    
    init() {
        lastLoadedId = nil
        canLoadMore = true
    }
    
    init(lastLoadedId: String?, canLoadMore: Bool) {
        self.lastLoadedId = lastLoadedId
        self.canLoadMore = canLoadMore
    }
}
