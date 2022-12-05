//
//  CreateNewPaymentMethodVC.swift
//  StripeTestApp
//
//  Created by Serhii on 05.12.2022.
//

import UIKit
import Stripe

final class CreateNewPaymentMethodVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet private weak var creditCardTextField: STPPaymentCardTextField!
    @IBOutlet private weak var createAndAttachPaymentButton: UIButton!
    
    // MARK: VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Private functions
    // MARK: Action
    @IBAction private func didTapCreateAndAttachPaymentButton(_ sender: Any) {
        createPaymentMethod()
    }
    
    // MARK: UI
    private func setupUI() {
        creditCardTextField.postalCodeEntryEnabled = false
        createAndAttachPaymentButton.setTitle("Create & Attach payment method", for: .normal)
    }
    
    // MARK: Other
    private func createPaymentMethod() {
        guard creditCardTextField.isValid else { return ProgressHUD.show(error: "Credit card data is invalid") }
        
        ProgressHUD.show()
        STPAPIClient.shared.createPaymentMethod(with: creditCardTextField.paymentMethodParams) { [weak self] paymentMethod, error in
            if let paymentMethodUnwrapped = paymentMethod {
                self?.attachPaymentMethodToCustomer(paymentMethodUnwrapped.stripeId)
            } else {
                ProgressHUD.show(error: error?.localizedDescription ?? "no error description")
            }
        }
    }
    
    private func attachPaymentMethodToCustomer(_ paymentId: String) {
        ServerNetworkManager().attach(paymentMethodId: paymentId) {
            switch $0 {
            case .success(let response):
                ProgressHUD.show(success: "Payment method attached to customer with id: \(response.customerId), card info: \(response.creditCard.description)")
            case .failure(let error):
                ProgressHUD.show(error: error.localizedDescription)
            }
        }
    }
}

// MARK: - STPAuthenticationContext
extension CreateNewPaymentMethodVC: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        self
    }
}
