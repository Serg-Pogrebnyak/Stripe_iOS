//
//  UIRefreshControlExtension.swift
//  StripeTestApp
//
//  Created by Serhii on 25.11.2022.
//

import UIKit

extension UIRefreshControl {
    func beginRefreshingManually() {
        DispatchQueue.main.async {
            guard !self.isRefreshing else { return }
            self.superview?.layoutIfNeeded()
            if let scrollView = self.superview as? UIScrollView {
                scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - self.frame.height), animated: true)
            }
            self.beginRefreshing()
        }
    }
}
