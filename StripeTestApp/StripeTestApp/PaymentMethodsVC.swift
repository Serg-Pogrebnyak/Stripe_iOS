//
//  PaymentMethodsVC.swift
//  StripeTestApp
//
//  Created by Serhii on 25.11.2022.
//

import UIKit

final class PaymentMethodsVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet private weak var paymentMethodsTableView: UITableView!
    
    // MARK: Variables
    private var creditCards = [SavedCard]() {
        didSet {
            refreshControl.endRefreshing()
            paymentMethodsTableView.reloadData()
        }
    }
    
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
    
    // MARK: Other
    private func fetchSavedCreditCards() {
        ServerNetworkManager().getSavedCC() { [weak self] in
            switch $0 {
            case .success(let creditCards):
                self?.creditCards = creditCards
            case .failure(let error):
                ProgressHUD.show(error: error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension PaymentMethodsVC: UITableViewDataSource {
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
