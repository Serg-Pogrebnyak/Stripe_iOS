//
//  CreditCardListVC.swift
//  StripeTestApp
//
//  Created by Serhii on 25.11.2022.
//

import UIKit

final class CreditCardListVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet private weak var paymentMethodsTableView: UITableView!
    
    // MARK: Variables
    private var creditCards = [SavedCard]()
    
    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(draggingRefreshControl), for: .valueChanged)
        
        return view
    }()
    
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
        paymentMethodsTableView.reloadData()
        fetchSavedCreditCards()
        refreshControl.beginRefreshingManually()
    }
    
    // MARK: UI
    private func setupUI() {
        paymentMethodsTableView.refreshControl = refreshControl
    }
    
    private func endRefreshingAndReloadTableView() {
        refreshControl.endRefreshing()
        paymentMethodsTableView.reloadData()
    }
    
    // MARK: Other
    private func fetchSavedCreditCards() {
        ServerNetworkManager().getSavedCC() { [weak self] in
            switch $0 {
            case .success(let creditCards):
                self?.creditCards = creditCards
                self?.endRefreshingAndReloadTableView()
            case .failure(let error):
                ProgressHUD.show(error: error.localizedDescription)
            }
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
        ProgressHUD.show()
//        success flow
//        ProgressHUD.hide()
//        creditCards.remove(at: indexPath.row)
//        paymentMethodsTableView.deleteRows(at: [indexPath], with: .automatic)
//        callback(true)
        
//        failure flow
//        ProgressHUD.hide()
//        callback(false)
    }
}

// MARK: - UITableViewDataSource
extension CreditCardListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        creditCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard creditCards.indices.contains(indexPath.row) else { return .init() }
        let cell = UITableViewCell()
        cell.textLabel?.text = creditCards[indexPath.row].description
        return cell
    }
}

extension CreditCardListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: R.string.localizable.delete()) { [weak self] (_, _, completionHandler) in
            self?.showAreYouSureAlert(toConfirmDeleteAt: indexPath,
                                      trailingActionCallback: completionHandler)
        }
        
        return .init(actions: [deleteAction])
    }
}
