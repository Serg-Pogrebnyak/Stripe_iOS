//
//  Parameters+Ext.swift
//  StripeTestApp
//
//  Created by Serhii on 01.12.2022.
//

import Alamofire

extension Parameters {
    func toPath() -> String {
        guard !isEmpty else { return .init() }
        return "?" + map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    }
}
