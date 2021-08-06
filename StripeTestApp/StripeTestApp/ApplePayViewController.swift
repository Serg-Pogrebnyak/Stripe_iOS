//
//  ApplePayViewController.swift
//  StripeTestApp
//
//  Created by Sergey Pohrebnuak on 04.08.2021.
//

import UIKit
import PassKit
import Stripe

final class ApplePayViewController: UIViewController {
    
    private lazy var applePayButton: PKPaymentButton = {
        let button = PKPaymentButton(paymentButtonType: .plain,
                                     paymentButtonStyle: .black)
        button.addTarget(self,
                         action: #selector(handleApplePayButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(applePayButton)
        
        applePayButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    @objc
    private func handleApplePayButtonTapped() {
        let merchantIdentifier = "merchant.id"
            let paymentRequest = StripeAPI.paymentRequest(withMerchantIdentifier: merchantIdentifier,
                                                          country: "US",
                                                          currency: "USD")
        paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "iHats, Inc", amount: 50.00)]
        if let applePayContext = STPApplePayContext(paymentRequest: paymentRequest, delegate: self) {
            applePayContext.presentApplePay(on: self)
        } else {
            print("❌error")
        }
    }
}
extension ApplePayViewController: STPApplePayContextDelegate {
    func applePayContext(_ context: STPApplePayContext, didCreatePaymentMethod paymentMethod: STPPaymentMethod, paymentInformation: PKPayment, completion: @escaping STPIntentClientSecretCompletionBlock) {
        let clientSecret = "" // from api call - payment_intents
        completion(clientSecret, nil)
    }
    func applePayContext(_ context: STPApplePayContext, didCompleteWith status: STPPaymentStatus, error: Error?) {
          switch status {
        case .success:
            print("✅ success")
        case .error:
            print("❌ error")
        case .userCancellation:
            print("❌ userCancellation")
        @unknown default:
            print("❌ unknown default")
        }
    }
}
