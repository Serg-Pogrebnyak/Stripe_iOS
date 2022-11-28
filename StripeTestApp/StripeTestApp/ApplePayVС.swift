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
    @IBOutlet private weak var amountTextField: AmountTextField!
    @IBOutlet private weak var applePayButton: PKPaymentButton!
    
    // MARK: VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Private functions
    // MARK: Action
    @IBAction private func didTapApplePayButton(_ sender: Any) {
        guard   amountTextField.isValid,
                let amount = amountTextField.amount else { return ProgressHUD.show(error: "Amount is incorrect") }
        
        let paymentRequest = StripeAPI.paymentRequest(withMerchantIdentifier: Constants.merchantId,
                                                      country: "US",
                                                      currency: "USD")
        paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "iHats, Inc",
                                                                   amount: NSDecimalNumber(value: amount))]
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
}

// MARK: - STPApplePayContextDelegate
extension ApplePayVС: STPApplePayContextDelegate {
    func applePayContext(_ context: STPApplePayContext, didCreatePaymentMethod paymentMethod: STPPaymentMethod, paymentInformation: PKPayment, completion: @escaping STPIntentClientSecretCompletionBlock) {
        guard let amount = amountTextField.amount else { return ProgressHUD.show(error: "Amount is incorrect") }
        
        ServerNetworkManager().createSecret(forAmount: AmountConverter.amountToCents(amount)) {
            switch $0 {
            case .success(let secret):
                completion(secret, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
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
