//
//  CreatePaymentIntent.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import Foundation

protocol CreatePaymentIntentType {
    var amount: Int { get }
    var customer: Customer { get }
}

struct CreatePaymentIntentModel: CreatePaymentIntentType {
    let amount: Int
    let customer: Customer
}
