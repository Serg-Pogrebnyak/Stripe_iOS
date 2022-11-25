//
//  ApplePayVС.swift
//  StripeTestApp
//
//  Created by Sergey Pohrebnuak on 04.08.2021.
//

import UIKit
import PassKit
import Stripe

final class ApplePayVС: UIViewController {
    
    // MARK: Outlets
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var applePayButton: PKPaymentButton!
    
    // MARK: VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Private functions
    // MARK: @IBAction
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
    
    // MARK: UI
    private func setupUI() {
        amountTextField.placeholder = "Please enter amount to pay"
    }
    
    // MARK: Other
}

// MARK: - STPApplePayContextDelegate
extension ApplePayVС: STPApplePayContextDelegate {
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
