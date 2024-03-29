//
//  PaymentMethodsProvider.swift
//  StripeTestApp
//
//  Created by Serhii on 25.11.2022.
//

import Alamofire

enum PaymentMethodsProvider: URLRequestBuilder {
    case attach(AttachPaymentMethodDTO)
    case listOfSaved(String)
    case detach(String)
    
    var path: String {
        switch self {
        case .attach(let modelDTO):
            return "payment_methods/\(modelDTO.paymentMethodId)/attach"
        case .listOfSaved:
            return "payment_methods"
        case .detach(let id):
            return "payment_methods/\(id)/detach"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .attach:
            return .post
        case .listOfSaved:
            return .get
        case .detach:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .attach(let modelDTO):
            return ["customer": modelDTO.customerId]
        case .listOfSaved(let customerId):
            return ["customer": customerId,
                    "type": "card"]
        case .detach:
            return nil
        }
    }
}
