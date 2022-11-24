//
//  ProgressHUD.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import SVProgressHUD

struct ProgressHUD {
    
    static func show() {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultAnimationType(.native)
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }
    
    static func hide() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
    static func show(success: String) {
        DispatchQueue.main.async {
            SVProgressHUD.showSuccess(withStatus: success)
        }
    }
    
    static func show(error: String) {
        DispatchQueue.main.async {
            SVProgressHUD.showError(withStatus: error)
        }
    }
}
