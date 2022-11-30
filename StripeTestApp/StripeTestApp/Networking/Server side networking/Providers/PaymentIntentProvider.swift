//
//  PaymentIntentProvider.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import Alamofire

enum PaymentIntentProvider: URLRequestBuilder {
    case getAll(PaymentIntentPaginationType)
    case create(CreatePaymentIntentType)
    case createFromSaved(CreatePaymentIntentType, CreditCard)
    
    var path: String {
        switch self {
        case .getAll(let pagination):
            var path = "payment_intents?limit=\(pagination.limit)"
            if let lastLoadedId = pagination.lastLoadedId {
                path += "&starting_after=\(lastLoadedId)"
            }
            return path
        case .create, .createFromSaved:
            return "payment_intents"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAll:
            return .get
        case .create, .createFromSaved:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getAll:
            return nil
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
