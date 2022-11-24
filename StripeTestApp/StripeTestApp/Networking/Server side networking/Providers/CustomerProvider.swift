//
//  CustomerProvider.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import Alamofire

enum CustomerProvider: URLRequestBuilder {
    case customers
    
    var path: String {
        switch self {
        case .customers:
            return "customers"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .customers:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .customers:
            return nil
        }
    }
}
