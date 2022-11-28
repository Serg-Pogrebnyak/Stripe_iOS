//
//  CreditCardListVC.swift
//  StripeTestApp
//
//  Created by Serhii on 25.11.2022.
//

import UIKit

final class CreditCardListVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet private weak var creditCardsTableView: UITableView!
    
    // MARK: Variables
    private var creditCards = [CreditCard]()
    
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
        creditCardsTableView.reloadData()
        fetchSavedCreditCards()
        refreshControl.beginRefreshingManually()
    }
    
    // MARK: UI
    private func setupUI() {
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
