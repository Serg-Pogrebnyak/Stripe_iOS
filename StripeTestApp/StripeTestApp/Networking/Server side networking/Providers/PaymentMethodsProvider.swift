//
//  PaymentMethodsProvider.swift
//  StripeTestApp
//
//  Created by Serhii on 25.11.2022.
//

import Alamofire

enum PaymentMethodsProvider: URLRequestBuilder {
    case saved(String)
    case detach(String)
    
    var path: String {
        switch self {
        case .saved:
            return "payment_methods"
        case .detach(let id):
            return "payment_methods/\(id)/detach"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .saved:
            return .get
        case .detach:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .saved(let customerId):
            return ["customer": customerId,
                    "type": "card"]
        case .detach:
            return nil
        }
    }
}
