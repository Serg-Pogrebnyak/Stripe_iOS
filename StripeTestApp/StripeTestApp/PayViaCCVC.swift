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
    // MARK: @IBAction
    @IBAction private func didTapPayButton(_ sender: Any) {
        guard let amount = Int(amountTextField.text ?? .init()) else {
            print("❌wrong amount") // TODO: show error here
            return
        }
        guard creditCardTextField.isValid else {
            print("❌card data is invalid") // TODO: show error here
            return
        }
        
        getCustomers(andPayWithAmount: amount)
    }
    
    // MARK: UI
    private func setupUI() {
        tabBarItem = .init(title: "Credit Cards", image: UIImage(named: "creditCardIcon"), tag: .zero)
        amountTextField.placeholder = "Please enter amount to pay"
        creditCardTextField.postalCodeEntryEnabled = false
        payButton.setTitle("Pay", for: .normal)
    }
    
    // MARK: Other
    private func getCustomers(andPayWithAmount amount: Int) {
        ServerNetworkManager().getUsers() { [weak self] result in
            switch result {
            case .success(let customers):
                guard let customer = customers.first else {
                    // TODO: show no customers
                    return
                }
                self?.createNewPayment(withAmount: amount, forCustomer: customer)
            case .failure(let error):
                print("❌", error) // TODO: show error here
            }
        }
    }
    
    private func createNewPayment(withAmount amount: Int, forCustomer customer: Customer) {
        ServerNetworkManager().createNewPayment(CreatePaymentIntentModel(amount: amount, customer: customer)) { [weak self] result in
            switch result {
            case .success(let paymentIntentModel):
                self?.makePayment(withSecret: paymentIntentModel.secret)
            case .failure(let error):
                print("❌", error)
            }
        }
    }
    
    private func makePayment(withSecret secret: String) {
        let methodIndent = STPPaymentIntentParams(clientSecret: secret)
        methodIndent.paymentMethodParams = creditCardTextField.paymentMethodParams
        //Save for future usage? yes - .offSession, no - .none
        methodIndent.setupFutureUsage = STPPaymentIntentSetupFutureUsage.offSession
        
        let paymentHandler = STPPaymentHandler.shared()
        
        paymentHandler.confirmPayment(methodIndent, with: self) { (status, paymentIntent, error) in
            switch (status) {
            case .failed:
                print("Payment failed")
            case .canceled:
                print("Payment canceled")
            case .succeeded:
                print("Payment succeeded", paymentIntent?.amount as Any)
            @unknown default:
                fatalError("unknown result")
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
