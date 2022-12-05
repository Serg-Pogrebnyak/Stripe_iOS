//
//  ProgressHUD.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import SVProgressHUD

struct ProgressHUD {
    
    static func show() {
        configureProgressHud()
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }
    
    static func hide() {
        configureProgressHud()
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
    static func show(success: String) {
        configureProgressHud()
        DispatchQueue.main.async {
            SVProgressHUD.showSuccess(withStatus: success)
        }
    }
    
    static func show(error: String) {
        configureProgressHud()
        DispatchQueue.main.async {
            SVProgressHUD.showError(withStatus: error)
        }
    }
    
    private static func configureProgressHud() {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setMaximumDismissTimeInterval(2)
    }
}
