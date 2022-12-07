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
        createAndAttachPaymentButton.setTitle(R.string.localizable.createNewPMCreateAndAttach(), for: .normal)
    }
    
    // MARK: Other
    private func createPaymentMethod() {
        guard creditCardTextField.isValid else { return ProgressHUD.show(error: R.string.localizable.createNewPMCardIsInvalid()) }
        
        ProgressHUD.show()
        STPAPIClient.shared.createPaymentMethod(with: creditCardTextField.paymentMethodParams) { [weak self] paymentMethod, error in
            if let paymentMethodUnwrapped = paymentMethod {
                self?.attachPaymentMethodToCustomer(paymentMethodUnwrapped.stripeId)
            } else {
                ProgressHUD.show(error: error?.localizedDescription ?? R.string.localizable.createNewPMSomeError())
            }
        }
    }
    
    private func attachPaymentMethodToCustomer(_ paymentId: String) {
        ServerNetworkManager().attach(paymentMethodId: paymentId) {
            switch $0 {
            case .success(let response):
                ProgressHUD.show(success: response.description)
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

fileprivate extension AttachPaymentMethodResponse {
    var description: String {
        [
            R.string.localizable.createNewPMAttachedTo() + customerId,
            R.string.localizable.createNewPMCardInfo() + creditCard.description
        ].joined(separator: ",")
    }
}
