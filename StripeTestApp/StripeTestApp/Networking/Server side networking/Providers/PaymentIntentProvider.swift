//
//  PaymentIntentProvider.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import Alamofire

enum PaymentIntentProvider: URLRequestBuilder {
    case create(CreatePaymentIntentType)
    case createFromSaved(CreatePaymentIntentType, CreditCard)
    
    var path: String {
        switch self {
        case .create, .createFromSaved:
            return "payment_intents"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .create, .createFromSaved:
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
        case .createFromSaved(let paymentIntentModel, let creditCard):
            return ["amount": paymentIntentModel.amount,
                    "customer": paymentIntentModel.customer.id,
                    "payment_method": creditCard.id,
                    "off_session": true.description,
                    "confirm": true.description,
                    "payment_method_types[]": "card",
                    "currency": "usd"]
        }
    }
}
