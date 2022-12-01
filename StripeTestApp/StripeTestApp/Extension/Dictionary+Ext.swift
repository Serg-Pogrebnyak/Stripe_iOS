//
//  Dictionary.swift
//  StripeTestApp
//
//  Created by Serhii on 01.12.2022.
//

import Foundation

extension Dictionary where Key == String, Value == Any? {
    func removeNil() -> [String: Any] {
        compactMapValues { $0 }
    }
}
