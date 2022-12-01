//
//  ProviderManager.swift
//  StripeTestApp
//
//  Created by Serhii on 21.11.2022.
//

import Alamofire

enum Result<T: Decodable> {
    case success(T)
    case failure(Error)
}

public enum ProviderManagerError: LocalizedError {
    case cantConvertToURLRequest
    case noInternetConnection
    
    public var errorDescription: String? {
        switch self {
        case .cantConvertToURLRequest:
            return "Cant convert service to URL request"
        case .noInternetConnection:
            return "No Internet connection. Please check your internet connection and try again"
        }
    }
}

final class ProviderManager<T: URLRequestBuilder> {
    
    private lazy var networkRechability = NetworkReachabilityManager()
    private var isConnectedToInternet:Bool { networkRechability?.isReachable ?? true }
    
    @discardableResult
    func send<U: Decodable>(service: T, decodeType: U.Type, callback: @escaping (Result<U>) -> Void) -> DataRequest? {
        guard isConnectedToInternet else {
            callback(.failure(ProviderManagerError.noInternetConnection))
            return nil
        }
        guard let urlRequest = service.urlRequest else {
            callback(.failure(ProviderManagerError.cantConvertToURLRequest))
            return nil
        }
        
        return AF.request(urlRequest).responseDecodable(of: U.self) { response in
            switch response.result {
            case .success(let model):
                callback(.success(model))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func send(service: T) {
        guard isConnectedToInternet else {
            print(ProviderManagerError.noInternetConnection)
            return
        }
        guard let urlRequest = service.urlRequest else {
            print(ProviderManagerError.cantConvertToURLRequest)
            return
        }
        
        AF.request(urlRequest).responseJSON { response in
            switch response.result {
            case .success(let json):
                print(json)
            case .failure(let error):
                print(error)
            }
        }
    }
}
