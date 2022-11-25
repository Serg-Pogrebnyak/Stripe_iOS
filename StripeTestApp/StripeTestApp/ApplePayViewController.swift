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
    
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var applePayButton: PKPaymentButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        
    }
    
    @IBAction private func didTapApplePayButton(_ sender: Any) {
        let paymentRequest = StripeAPI.paymentRequest(withMerchantIdentifier: Constants.merchantId,
                                                      country: "US",
                                                      currency: "USD")
        paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "iHats, Inc", amount: 0.50)]
        if let applePayContext = STPApplePayContext(paymentRequest: paymentRequest, delegate: self) {
            applePayContext.presentApplePay(completion: nil)
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
