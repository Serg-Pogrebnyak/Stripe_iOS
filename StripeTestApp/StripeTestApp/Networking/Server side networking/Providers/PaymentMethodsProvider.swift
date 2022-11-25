//
//  PaymentMethodsProvider.swift
//  StripeTestApp
//
//  Created by Serhii on 25.11.2022.
//

import Alamofire

enum PaymentMethodsProvider: URLRequestBuilder {
    case saved(String)
    
    var path: String {
        switch self {
        case .saved:
            return "payment_methods"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .saved:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .saved(let customerId):
            return ["customer": customerId,
                    "type": "card"]
        }
    }
}
