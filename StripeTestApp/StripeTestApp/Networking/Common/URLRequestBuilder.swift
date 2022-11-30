//
//  URLRequestBuilder.swift
//  StripeTestApp
//
//  Created by Serhii on 21.11.2022.
//

import Alamofire

protocol URLRequestBuilder: URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    var method: HTTPMethod { get }
}

extension URLRequestBuilder {
    
    private var privateSecretKeyBase64: String { Data(Constants.stripeSecretKey.utf8).base64EncodedString() }
    
    var baseURL: String { "https://api.stripe.com/v1/" }

    var headers: HTTPHeaders? {
        HTTPHeaders([
            .init(name: "Content-Type", value: "application/x-www-form-urlencoded"),
            .init(name: "Authorization", value: "Basic \(privateSecretKeyBase64)")
        ])
    }
    
    var parameters: Parameters? { return nil }
    
    func asURLRequest() throws -> URLRequest {
        let url = try (baseURL + path).asURL()
        
        var request = URLRequest(url: url)
        request.method = method
        request.allHTTPHeaderFields = headers?.dictionary
        let encoding = URLEncoding.default
        return try encoding.encode(request, with: parameters)
    }
}
