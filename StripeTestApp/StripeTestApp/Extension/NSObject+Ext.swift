//
//  NSObject+Ext.swift
//  StripeTestApp
//
//  Created by Serhii on 28.11.2022.
//

import Foundation

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
}
