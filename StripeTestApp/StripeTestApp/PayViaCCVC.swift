//
//  PayViaCCVC.swift
//  StripeTestApp
//
//  Created by Serhii on 24.11.2022.
//

import UIKit
import Stripe
import SnapKit

final class PayViaCCVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var creditCardTextField: STPPaymentCardTextField!
    @IBOutlet private weak var payButton: UIButton!
    
    // MARK: VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Private functions
    // MARK: Action
    @IBAction private func didTapPayButton(_ sender: Any) {
        guard let amount = Int(amountTextField.text ?? .init()) else { return ProgressHUD.show(error: "Amount is incorrect") }
        guard creditCardTextField.isValid else { return ProgressHUD.show(error: "Credit card data is invalid") }
        ProgressHUD.show()
        ServerNetworkManager().createSecret(forAmount: amount) { [weak self] result in
            switch result {
            case .success(let secret):
                self?.makePayment(withSecret: secret)
            case .failure(let error):
                ProgressHUD.show(error: error.localizedDescription)
            }
        }
    }
    
    // MARK: UI
    private func setupUI() {
        tabBarItem = .init(title: R.string.localizable.tabBarCreditCard(),
                           image: R.image.creditCardIcon(),
                           tag: .zero)
        amountTextField.placeholder = "Please enter amount to pay"
        creditCardTextField.postalCodeEntryEnabled = false
        payButton.setTitle("Pay", for: .normal)
    }
    
    private func makePayment(withSecret secret: String) {
        let methodIndent = STPPaymentIntentParams(clientSecret: secret)
        methodIndent.paymentMethodParams = creditCardTextField.paymentMethodParams
        //Save for future usage? yes - .offSession, no - .none
        methodIndent.setupFutureUsage = STPPaymentIntentSetupFutureUsage.offSession
        
        let paymentHandler = STPPaymentHandler.shared()
        
        paymentHandler.confirmPayment(methodIndent, with: self) { (status, paymentIntent, error) in
            switch status {
            case .failed:
                ProgressHUD.show(error: "Payment failed")
            case .canceled:
                ProgressHUD.show(error: "Payment canceled")
            case .succeeded:
                guard let amount = paymentIntent?.amount,
                      let currency = paymentIntent?.currency,
                      let customerId = paymentIntent?.paymentMethod?.customerId
                else {
                    ProgressHUD.show(success: "Payment succeeded! But no additional info")
                    return
                }
                ProgressHUD.show(success: "Payment succeeded! \n Order Amount: \(amount)\(currency) \n Customer id: \(customerId)")
            }
        }
    }
}

// MARK: - STPAuthenticationContext
extension PayViaCCVC: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        self
    }
}
