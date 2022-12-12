//
//  CreditCardListVC.swift
//  StripeTestApp
//
//  Created by Serhii on 25.11.2022.
//

import UIKit
import Stripe

final class CreditCardListVC: UIViewController {
    
    private struct PaymentDTO {
        let amount: Float
        let creditCard: CreditCard
    }
    
    // MARK: Outlets
    @IBOutlet private weak var amountTextField: AmountTextField!
    @IBOutlet private weak var amountDescriptionLabel: UILabel!
    @IBOutlet private weak var creditCardsTableView: UITableView!
    
    // MARK: Variables
    private var creditCards = [CreditCard]()
    
    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(draggingRefreshControl), for: .valueChanged)
        
        return view
    }()
    private lazy var paymentIntentHandler: STPPaymentHandlerActionPaymentIntentCompletionBlock = { (status, paymentIntent, error) in
        switch status {
        case .failed:
            let errorMessageDescription = [
                R.string.localizable.ccListPaymentFailed(),
                error?.description ?? .init()
            ]
            .filter { !$0.isEmpty}
            .joined(separator: "\n")
            ProgressHUD.show(error: errorMessageDescription)
        case .canceled:
            ProgressHUD.show(error:  R.string.localizable.ccListPaymentCanceled())
        case .succeeded:
            if let paymentIntent = paymentIntent {
                ProgressHUD.show(success: paymentIntent.paymentDescription)
            } else {
                ProgressHUD.show(success: R.string.localizable.paymentSucceeded())
            }
        }
    }
    
    // MARK: VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        draggingRefreshControl()
    }
    
    // MARK: - Private functions
    // MARK: Action
    @objc private func draggingRefreshControl() {
        creditCards.removeAll()
        creditCardsTableView.reloadData()
        fetchSavedCreditCards()
        refreshControl.beginRefreshingManually()
    }
    
    // MARK: UI
    private func setupUI() {
        amountTextField.placeholder = R.string.localizable.amountTextFieldPlaceholder()
        amountDescriptionLabel.text = R.string.localizable.ccListTextFieldDescriptionLabel()
        creditCardsTableView.refreshControl = refreshControl
    }
    
    private func endRefreshingAndReloadTableView() {
        refreshControl.endRefreshing()
        creditCardsTableView.reloadData()
    }
    
    // MARK: Other
    private func fetchSavedCreditCards() {
        ServerNetworkManager().getSavedCC() { [weak self] in
            switch $0 {
            case .success(let creditCards):
                self?.creditCards = creditCards
            case .failure(let error):
                ProgressHUD.show(error: error.localizedDescription)
            }
            
            self?.endRefreshingAndReloadTableView()
        }
    }
    
    private func showAreYouSureAlert(toConfirmDeleteAt indexPath: IndexPath, trailingActionCallback: @escaping (Bool) -> Void) {
        let yesAction: UIAlertAction = .init(withTitle: R.string.localizable.yes(), style: .destructive) { [weak self] _ in
            self?.deleteCC(at: indexPath, withTrailingActionCallback: trailingActionCallback)
        }
        
        let noAction: UIAlertAction = .init(withTitle: R.string.localizable.no()) { _ in
            trailingActionCallback(false)
        }
        
        showAlert(withTitle: R.string.localizable.ccListAreYouSure(),
                  message: R.string.localizable.ccListConfirmToDeleteAction(),
                  actions: [yesAction, noAction])
    }
    
    private func deleteCC(at indexPath: IndexPath, withTrailingActionCallback callback: @escaping (Bool) -> Void) {
        guard creditCards.indices.contains(indexPath.row) else { return }
        
        ProgressHUD.show()
        ServerNetworkManager().detach(creditCard: creditCards[indexPath.row]) { [weak self] result in
            ProgressHUD.hide()
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let removedCreditCard):
                if let removedCCIndex = strongSelf.creditCards.firstIndex(of: removedCreditCard) {
                    strongSelf.creditCards.remove(at: removedCCIndex)
                    strongSelf.creditCardsTableView.deleteRows(at: [.init(row: removedCCIndex, section: .zero)],
                                                               with: .automatic)
                    callback(true)
                } else {
                    ProgressHUD.show(error: R.string.localizable.ccListRemovedCardNotFound())
                    callback(false)
                }
            case .failure(let error):
                ProgressHUD.show(error: error.localizedDescription)
                callback(false)
            }
        }
    }
    
    private func showAlertToSelectPaymentProvider(paymentDTO: PaymentDTO) {
        let alertActions: [UIAlertAction] = [
            .init(withTitle: R.string.localizable.ccListPayLikeServer(), handler: { [weak self] _ in
                self?.makeNewPaymentFromSavedCCLikeFromServer(paymentDTO: paymentDTO)
            }),
            .init(withTitle: R.string.localizable.ccListPayLikePhone(), handler: { [weak self] _ in
                self?.makeNewPaymentFromSavedCCLikeFromPhone(paymentDTO: paymentDTO)
            }),
            .init(withTitle: R.string.localizable.cancel(), style: .destructive)
        ]
        showAlert(withTitle: R.string.localizable.ccListPayLike(), actions: alertActions)
    }
    
    private func makeNewPaymentFromSavedCCLikeFromServer(paymentDTO: PaymentDTO) {
        ProgressHUD.show()
        ServerNetworkManager().payViaSavedCC(amount: AmountConverter.amountToCents(paymentDTO.amount),
                                             creditCard: paymentDTO.creditCard)
        {
            switch $0 {
            case .success(let responseModel):
                ProgressHUD.show(success: responseModel.description)
            case .failure(let error):
                ProgressHUD.show(error: error.localizedDescription)
            }
        }
    }
    
    private func makeNewPaymentFromSavedCCLikeFromPhone(paymentDTO: PaymentDTO) {
        let amountInCents = AmountConverter.amountToCents(paymentDTO.amount)
        ProgressHUD.show()
        ServerNetworkManager().createSecret(forAmount: amountInCents) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let secret):
                let methodIntent = STPPaymentIntentParams(clientSecret: secret)
                methodIntent.paymentMethodId = paymentDTO.creditCard.id
                // NOTE: We should mark payment method for future usage, this will allow our server to make off session transactions
                methodIntent.setupFutureUsage = .offSession
                STPPaymentHandler.shared().confirmPayment(methodIntent,
                                                          with: strongSelf,
                                                          completion: strongSelf.paymentIntentHandler)
            case .failure(let error):
                ProgressHUD.show(error: error.localizedDescription)
            }
        }
    }
    
    private func makePaymentDTOOrShowError(byIndex indexPath: IndexPath) -> PaymentDTO? {
        if  amountTextField.isValid,
            creditCards.indices.contains(indexPath.row),
            let amount = amountTextField.amount
        {
            return .init(amount: amount, creditCard: creditCards[indexPath.row])
        } else {
            ProgressHUD.show(error: R.string.localizable.applePayAmountIsIncorrect())
            return nil
        }
    }
}

// MARK: - UITableViewDataSource
extension CreditCardListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = creditCards.isEmpty ? EmptyCreditCardListView() : nil
        return creditCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard creditCards.indices.contains(indexPath.row) else { return .init() }
        let cell = UITableViewCell()
        cell.textLabel?.text = creditCards[indexPath.row].description
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CreditCardListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let paymentDTO = makePaymentDTOOrShowError(byIndex: indexPath) else { return }
        showAlertToSelectPaymentProvider(paymentDTO: paymentDTO)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: R.string.localizable.delete()) { [weak self] (_, _, completionHandler) in
            self?.showAreYouSureAlert(toConfirmDeleteAt: indexPath,
                                      trailingActionCallback: completionHandler)
        }
        
        return .init(actions: [deleteAction])
    }
}

// MARK: - STPAuthenticationContext
extension CreditCardListVC: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        self
    }
}

// MARK: - PaymentIntent Extension
fileprivate extension PaymentIntent {
    var description: String {
        R.string.localizable.paymentSucceededWithStatus() + status + "\n" +
        R.string.localizable.orderAmount() + amount.description + currency + "\n" +
        R.string.localizable.customerId() + customerId
    }
}

// MARK: - STPPaymentIntent Extension
extension STPPaymentIntent {
    var paymentDescription: String {
        let amountToDisplay = AmountConverter.centsToAmount(amount)
        var description =   R.string.localizable.paymentSucceededWithStatus() + status.description + "\n" +
                            R.string.localizable.orderAmount() + amountToDisplay.description + currency + "\n"
        if let customerId = paymentMethod?.customerId {
            description.append(R.string.localizable.customerId() + customerId)
        }
        return description
    }
}
