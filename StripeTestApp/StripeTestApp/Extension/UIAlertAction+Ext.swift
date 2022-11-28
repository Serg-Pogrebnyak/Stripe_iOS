//
//  UIAlertAction+Ext.swift
//  StripeTestApp
//
//  Created by Serhii on 28.11.2022.
//

import UIKit

extension UIAlertAction {
    convenience init(withTitle: String, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: withTitle,
                  style: style,
                  handler: handler)
    }
}
