//
//  MainViewController.swift
//  homework4.4
//
//  Created by Zhansuluu Kydyrova on 1/1/23.
//

import UIKit
import RxSwift

class MainViewController: UIViewController {

    @IBOutlet private weak var orderTypeCollectionView: UICollectionView!
    @IBOutlet private weak var takeawaysTableview: UITableView!
    
    
    private let disposeBag = DisposeBag()
    private var products: Observable<[ProductModel]>?
    
    
    private var orderTypeArray = [OrderTypeModel]()
    private var takeAways = [ProductModel]() {
        didSet {
            filteredTakeAways = takeAways
            takeawaysTableview.reloadData()
        }
    }
    private var filteredTakeAways = [ProductModel]()
    
    private var smartphonesArray = [ProductModel]()
    private var laptopsArray = [ProductModel]()
    private var fragrancesArray = [ProductModel]()
    private var groceriesArray = [ProductModel]()
    private var homeDecorationArray = [ProductModel]()
    private var skincareArray = [ProductModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureData()
        configureTakeawayDataArray()
        orderTypeArray = NetworkLayer.shared.decodeOrderTypeData(json)
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
            return orderTypeArray.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OrderTypeCollectionViewCell.reuseID,
                for: indexPath) as? OrderTypeCollectionViewCell else { fatalError() }
            
            let orderType = orderTypeArray[indexPath.row]
            cell.displayOrderType(orderType)
            return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView (
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
            return CGSize(width: 100, height: 115)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
           configureCategoryArrays(indexPath: indexPath)
           takeawaysTableview.reloadData()
            
        
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTakeAways.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TakeawaysTableViewCell.tableViewCellReuseID,
            for: indexPath) as? TakeawaysTableViewCell else { fatalError() }
        
        let product = filteredTakeAways[indexPath.row]
        cell.displayInfo(product)
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 380
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            handleDeleteTakeaways(indexPath: indexPath)
        }
    }
}

extension MainViewController {
        
        private func configureTakeawayDataArray()  {
            self.products = NetworkLayer.shared.fetchProductsData()
            Task {
                if let takeAways = try await products?.toArray().value.first {
                    self.takeAways = takeAways
                }
            }
        }
    
    private func configureData() {
        
        orderTypeCollectionView.dataSource = self
        orderTypeCollectionView.delegate = self
        orderTypeCollectionView.register(
            UINib(nibName: String(describing: OrderTypeCollectionViewCell.self), bundle: nil),
            forCellWithReuseIdentifier: OrderTypeCollectionViewCell.reuseID)
        
        takeawaysTableview.dataSource = self
        takeawaysTableview.delegate = self
        takeawaysTableview.register(
            UINib(nibName: String(describing: TakeawaysTableViewCell.self), bundle: nil),
            forCellReuseIdentifier: TakeawaysTableViewCell.tableViewCellReuseID)
    }
    
    private func handleDeleteTakeaways(indexPath:IndexPath) {
        let id = takeAways[indexPath.row].id
        deleteTakeaways(by: id)
        takeAways.remove(at: indexPath.row)
        takeawaysTableview.deleteRows(at: [indexPath], with: .automatic)
    }
    
    private func deleteTakeaways(by id: Int) {
        Task {
            do {
                _ = try await NetworkLayer.shared.deleteProductsData(id: id)
            }
        }
    }
    
    private func display(_ error: Error) {
        print("\(error.localizedDescription)")
    }
    
    private func configureCategoryArrays(indexPath: IndexPath) {
        let category = orderTypeArray[indexPath.row].orderLabel.lowercased()
        filteredTakeAways = takeAways.filter { $0.category == category }

    }
    
    private func handleconfigureCategoryArrays() {
        smartphonesArray = takeAways.filter({$0.category == "smartphones"})
        laptopsArray = takeAways.filter({$0.category == "laptops"})
        fragrancesArray = takeAways.filter({$0.category == "fragrances"})
        groceriesArray = takeAways.filter({$0.category == "groceries"})
        homeDecorationArray = takeAways.filter({$0.category == "home-decoration"})
        skincareArray = takeAways.filter({$0.category == "skincare"})
    }
}
