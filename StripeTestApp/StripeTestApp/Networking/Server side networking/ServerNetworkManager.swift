//
//  ServerNetworkManager.swift
//  StripeTestApp
//
//  Created by Serhii on 21.11.2022.
//

import Foundation
import Alamofire

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
    
    private var getPaymentsRequest: DataRequest?
    
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
    
    func getSavedCC(callback: @escaping (Result<[CreditCard]>) -> Void) {
        getUsers {
            switch $0 {
            case .success(let customers):
                guard let customer = customers.first else {
                    return callback(.failure(ServerNetworkManagerError.usersListEmpty))
                }
                ProviderManager().send(service: PaymentMethodsProvider.listOfSaved(customer.id),
                                       decodeType: PaymentMethodsResponse.self) {
                    switch $0 {
                    case .success(let paymentMethodsResponse):
                        callback(.success(paymentMethodsResponse.creditCards))
                    case .failure(let error):
                        callback(.failure(error))
                    }
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func payViaSavedCC(amount: Int, creditCard: CreditCard, callback: @escaping (Result<PaymentIntent>) -> Void) {
        getUsers {
            switch $0 {
            case .success(let customers):
                guard let customer = customers.first else {
                    return callback(.failure(ServerNetworkManagerError.usersListEmpty))
                }
                let paymentIntentModel = CreatePaymentIntentModel(amount: amount, customer: customer)
                let service = PaymentIntentProvider.createFromSaved(paymentIntentModel,
                                                                    creditCard)
                ProviderManager().send(service: service,
                                       decodeType: PaymentIntent.self,
                                       callback: callback)
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func attach(paymentMethodId: String, callback: @escaping (Result<AttachPaymentMethodResponse>) -> Void) {
        getUsers {
            switch $0 {
            case .success(let customers):
                guard let customer = customers.first else {
                    return callback(.failure(ServerNetworkManagerError.usersListEmpty))
                }
                let attachPaymentMethodDTO = AttachPaymentMethodDTO(customerId: customer.id,
                                                                    paymentMethodId: paymentMethodId)
                ProviderManager().send(service: PaymentMethodsProvider.attach(attachPaymentMethodDTO),
                                       decodeType: AttachPaymentMethodResponse.self,
                                       callback: callback)
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func detach(creditCard: CreditCard, callback: @escaping (Result<CreditCard>) -> Void) {
        ProviderManager().send(service: PaymentMethodsProvider.detach(creditCard.id),
                               decodeType: CreditCard.self,
                               callback: callback)
    }
    
    func getPayments(pagination: PaginationType, callback: @escaping (Result<PaymentIntentsResponse>) -> Void) {
        getPaymentsRequest?.cancel()
        getPaymentsRequest = ProviderManager().send(service: PaymentIntentProvider.getAll(pagination),
                                                    decodeType: PaymentIntentsResponse.self,
                                                    callback: callback)
    }
    
    func getCustomers(pagination: PaginationType, callback: @escaping (Result<CustomerResponse>) -> Void) {
        ProviderManager().send(service: CustomerProvider.customers,
                               decodeType: CustomerResponse.self,
                               callback: callback)
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
