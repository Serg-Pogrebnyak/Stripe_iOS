//
//  AmountConverter.swift
//  StripeTestApp
//
//  Created by Serhii on 28.11.2022.
//

import Foundation

struct AmountConverter {
    static func amountToCents(_ amount: Float) -> Int {
        Int(amount * 100)
    }
    
    static func centsToAmount(_ cents: Int) -> Float {
        Float(cents) / 100
    }
}
