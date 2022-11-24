//
//  PaymentIntentProvider.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import Alamofire

enum PaymentIntentProvider: URLRequestBuilder {
    case create(CreatePaymentIntentType)
    
    var path: String {
        switch self {
        case .create:
            return "payment_intents"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .create:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .create(let paymentIntentModel):
            return ["amount": paymentIntentModel.amount,
                    "customer": paymentIntentModel.customer.id,
                    "payment_method_types[]": "card",
                    "currency": "usd"]
        }
    }
}
