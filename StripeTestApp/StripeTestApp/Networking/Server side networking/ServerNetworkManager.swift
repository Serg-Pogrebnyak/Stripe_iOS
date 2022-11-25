//
//  ServerNetworkManager.swift
//  StripeTestApp
//
//  Created by Serhii on 21.11.2022.
//

import Foundation

//TODO: Just remove this in future
public enum ServerNetworkManagerError: LocalizedError {
    case usersListEmpty
    
    public var errorDescription: String? {
        switch self {
        case .usersListEmpty:
            return "Users list is empty, create new user and try again"
        }
    }
}

protocol ServerNetworkManagerType {
    func createSecret(forAmount amount: Int, callback: @escaping (Result<String>) -> Void)
}

final class ServerNetworkManager: ServerNetworkManagerType {
    
    func createSecret(forAmount amount: Int, callback: @escaping (Result<String>) -> Void) {
        getUsers {
            switch $0 {
            case .success(let customers):
                if let customer = customers.first {
                    self.createNewPayment(CreatePaymentIntentModel(amount: amount, customer: customer),
                                          callback: callback)
                } else {
                    callback(.failure(ServerNetworkManagerError.usersListEmpty))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    // MARK: Customers
    private func getUsers(_ callback: @escaping (Result<[Customer]>) -> Void) {
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
    private func createNewPayment(_ paymentModel: CreatePaymentIntentType, callback: @escaping (Result<String>) -> Void) {
        ProviderManager().send(service: PaymentIntentProvider.create(paymentModel), decodeType: PaymentIntent.self) {
            switch $0 {
            case .success(let paymentIntent):
                callback(.success(paymentIntent.secret))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
}
