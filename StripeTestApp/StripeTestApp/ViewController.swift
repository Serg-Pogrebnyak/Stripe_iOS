//
//  ViewController.swift
//  StripeTestApp
//
//  Created by Sergey Pohrebnuak on 04.08.2021.
//

import UIKit
import Stripe
import SnapKit

class ViewController: UIViewController {
    
    lazy var cardView1: STPCardFormView = {
        let view = STPCardFormView(style: .borderless)
        
        return view
    }()
    
    lazy var cardView2: STPPaymentCardTextField = {
        let view = STPPaymentCardTextField()
        view.postalCodeEntryEnabled = false
        
        return view
    }()
    
    lazy var addCardVC: STPAddCardViewController = {
        let vc = STPAddCardViewController()
        
        return vc
    }()
    
    lazy var addCardButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Add credit card", for: .normal)
        button.addTarget(self, action: #selector(didTapAddCardButton), for: .touchUpInside)

        return button
    }()
    lazy var testPaymentWithMockDataButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Test payment with credit card data", for: .normal)
        button.addTarget(self, action: #selector(testPaymentWithMockData), for: .touchUpInside)

        return button
    }()
    //let cardVC = STPPaymentOptionsViewController()
    
    private let publishKey = "" // from stripe dashboard
    private let clientSecret = "" // from api call - payment_intents
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StripeAPI.defaultPublishableKey = publishKey
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(cardView1)
        view.addSubview(cardView2)
        view.addSubview(addCardButton)
        view.addSubview(testPaymentWithMockDataButton)
        
        cardView1.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.center.equalToSuperview()
        }
        cardView2.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(cardView1.snp.bottom)
        }
        addCardButton.snp.makeConstraints {
            $0.top.equalTo(cardView2.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        testPaymentWithMockDataButton.snp.makeConstraints {
            $0.top.equalTo(addCardButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
    
    @objc
    private func didTapAddCardButton() {
        present(addCardVC, animated: true, completion: nil)
    }
    
    @objc
    private func handleResultAfterPaymentViaExistedCreditCard() {
        let clientSecret = "" // secret cay from server after https://api.stripe.com/v1/payment_intents api call with payment_method parameter
        STPAPIClient.shared.retrievePaymentIntent(withClientSecret: clientSecret) { (paymentIntent, error) in
            //if success - return
            //if error - show error and try again with 3ds authorization or try to get new credit card info
            guard error == nil,
                  let clientSecret = paymentIntent?.clientSecret,
                  let lastPaymentError = paymentIntent?.lastPaymentError,
                  let stripeId = lastPaymentError.paymentMethod?.stripeId
            else {
                print(error as Any) // show error to user
                return
            }
            
            var failureReason = "Payment failed, try again."
            if lastPaymentError.type == .card, let error = lastPaymentError.message {
                failureReason = error
            }
            print(failureReason) // show error to user

            let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
            if lastPaymentError.code == "authentication_required" {
                paymentIntentParams.paymentMethodId = stripeId
            } else {
                fatalError("Collect a new PaymentMethod from the customer...")
            }

            let paymentHandler = STPPaymentHandler.shared()
            paymentHandler.confirmPayment(paymentIntentParams, with: self) { (status, paymentIntent, error) in
                switch (status) {
                case .failed:
                    print("Payment failed", error as Any)
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
    
    @objc
    private func testPaymentWithMockData() {
        // NOTE: if you want use your own text field for collect data
        let stripeCardParams = STPCardParams()
        stripeCardParams.number = "4000008260003178"
        stripeCardParams.expMonth = 11
        stripeCardParams.expYear = 23
        stripeCardParams.cvc = "123"

        let cardParams = STPPaymentMethodCardParams(cardSourceParams: stripeCardParams)
        let methodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
        let methodIndent = STPPaymentIntentParams(clientSecret: .init())
        methodIndent.paymentMethodParams = cardView2.paymentMethodParams// NOTE: for more details see
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

extension ViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}
