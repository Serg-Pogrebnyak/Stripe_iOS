//
//  ServerNetworkManager.swift
//  StripeTestApp
//
//  Created by Serhii on 21.11.2022.
//

import Foundation

protocol ServerNetworkManagerType {
    func getUsers(_ callback: @escaping (Result<[Customer]>) -> Void)
    func createNewPayment(_ paymentModel: CreatePaymentIntentType, callback: @escaping (Result<PaymentIntent>) -> Void)
}

final class ServerNetworkManager: ServerNetworkManagerType {
    // MARK: Customers
    func getUsers(_ callback: @escaping (Result<[Customer]>) -> Void) {
        ProviderManager().send(service: CustomerProvider.customers, decodeType: CustomerResponse.self) { result in
            switch result {
            case .success(let customerResponse):
                callback(.success(customerResponse.customers))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    // MARK: Payment Intents
    func createNewPayment(_ paymentModel: CreatePaymentIntentType, callback: @escaping (Result<PaymentIntent>) -> Void) {
        ProviderManager().send(service: PaymentIntentProvider.create(paymentModel), decodeType: PaymentIntent.self) {
            callback($0)
        }
    }
}
