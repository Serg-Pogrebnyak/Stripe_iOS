//
//  PaymentIntentsListVC.swift
//  StripeTestApp
//
//  Created by Serhii on 30.11.2022.
//

import UIKit

final class PaymentIntentsListVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet private weak var paymentIntentTableView: UITableView!
    
    // MARK: Constants
    let serverNetworkManager = ServerNetworkManager()
    
    // MARK: Variables
    private var paymentIntents = [PaymentIntent]()
    private var pagination: PaginationType = Pagination()
    
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
        pagination = Pagination()
        paymentIntents.removeAll()
        paymentIntentTableView.reloadData()
        fetchPaymentIntents()
        refreshControl.beginRefreshingManually()
    }
    
    // MARK: UI
    private func setupUI() {
        paymentIntentTableView.refreshControl = refreshControl
    }
    
    private func endRefreshingAndReloadTableView() {
        refreshControl.endRefreshing()
        paymentIntentTableView.reloadData()
    }
    
    // MARK: Other
    private func fetchPaymentIntents() {
        serverNetworkManager.getPayments(pagination: pagination) { [weak self] in
            switch $0 {
            case .success(let paymentIntentResponse):
                self?.paymentIntents.append(contentsOf: paymentIntentResponse.paymentIntents)
                self?.pagination = paymentIntentResponse.pagination
                self?.endRefreshingAndReloadTableView()
            case .failure(let error):
                ProgressHUD.show(error: error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension PaymentIntentsListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = paymentIntents.isEmpty ? EmptyPaymentsListView() : nil
        return paymentIntents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard paymentIntents.indices.contains(indexPath.row) else { return .init() }
        let cell = UITableViewCell()
        cell.textLabel?.text = paymentIntents[indexPath.row].description
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PaymentIntentsListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if paymentIntents.indices.last == indexPath.row && pagination.canLoadMore {
            fetchPaymentIntents()
        }
    }
}

// MARK: - PaymentIntent Extension
fileprivate extension PaymentIntent {
    var description: String {
        "\(amount.description)\(currency) \(status) \(id.suffix(6))"
    }
}
