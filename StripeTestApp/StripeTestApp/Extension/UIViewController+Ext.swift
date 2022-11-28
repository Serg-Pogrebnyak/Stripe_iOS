//
//  UIViewController+Ext.swift
//  StripeTestApp
//
//  Created by Serhii on 28.11.2022.
//

import UIKit

extension UIViewController {
    func showAlert(withTitle title: String, message: String? = nil, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
       
        DispatchQueue.main.async { [weak self] in
            guard self?.presentedViewController == nil else { return }
            self?.present(alert, animated: false, completion: nil)
        }
    }
}
