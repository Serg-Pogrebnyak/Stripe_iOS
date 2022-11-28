//
//  CharacterSet+Ext.swift
//  StripeTestApp
//
//  Created by Serhii on 28.11.2022.
//

import Foundation

extension CharacterSet {
    static var decimalDigitsWithSeparator: Self {
        .decimalDigits.union(CharacterSet(charactersIn: NumberFormatter().decimalSeparator))
    }
}
