//
//  CustomersListVC.swift
//  StripeTestApp
//
//  Created by Serhii on 01.12.2022.
//

import UIKit

final class CustomersListVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet private weak var customersTableView: UITableView!
    
    // MARK: Constants
    let serverNetworkManager = ServerNetworkManager()
    
    // MARK: Variables
    private var customers = [Customer]()
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
        customers.removeAll()
        customersTableView.reloadData()
        fetchCustomers()
        refreshControl.beginRefreshingManually()
    }
    
    // MARK: UI
    private func setupUI() {
        customersTableView.refreshControl = refreshControl
    }
    
    private func endRefreshingAndReloadTableView() {
        refreshControl.endRefreshing()
        customersTableView.reloadData()
    }
    
    // MARK: Other
    private func fetchCustomers() {
        serverNetworkManager.getCustomers(pagination: pagination) { [weak self] in
            switch $0 {
            case .success(let paymentIntentResponse):
                self?.customers.append(contentsOf: paymentIntentResponse.customers)
                self?.pagination = paymentIntentResponse.pagination
                self?.endRefreshingAndReloadTableView()
            case .failure(let error):
                ProgressHUD.show(error: error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension CustomersListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard customers.indices.contains(indexPath.row) else { return .init() }
        let cell = UITableViewCell()
        cell.textLabel?.text = customers[indexPath.row].descriptionToDisplay
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CustomersListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if customers.indices.last == indexPath.row && pagination.canLoadMore {
            fetchCustomers()
        }
    }
}

// MARK: - Customer Extension
fileprivate extension Customer {
    var descriptionToDisplay: String {
        "\(description) \(id)"
    }
}

