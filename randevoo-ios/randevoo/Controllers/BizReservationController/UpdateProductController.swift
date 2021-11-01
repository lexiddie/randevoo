//
//  UpdateProductController.swift
//  randevoo
//
//  Created by Lex on 30/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import ObjectMapper
import SwiftyJSON
import Alamofire
import AlamofireImage
import Cache
import SnapKit
import Hydra

class UpdateProductController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UpdateProductCellDelegate {

    var previousController: UIViewController!
    var reservedProducts: [Product] = []
    var cachedProducts: [Product] = []
    var products: [Product] = []
    
    private let alertHelper = AlertHelper()
    private let db = Firestore.firestore()
    private var productRef: CollectionReference!
    private var alertController: UIAlertController!
    
    private let updateProductCell = "updateProductCell"
    private var updateCollectionView: UICollectionView!
    
    private var isFirst: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialCollectionView()
        initiateFirestore()
        getProducts()
        
        self.alertHelper.showAlert(title: "Notice", alert: "Your completed a reservation to your customer😎", controller: self)
    }
    
    func loadUpdate() {
        if isFirst {
            updateCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            getProducts()
        }
    }
    
    private func getProducts() {
        isFirst = true
        var tempList: [Product] = []
        for i in cachedProducts {
            let current = i.copy()
            current.variants.removeAll()
            for j in reservedProducts {
                let reservedVariant = j.variants[0]
                if let variant = i.variants.first(where: {$0.color == reservedVariant.color && $0.size == reservedVariant.size && i.id == j.id}) {
                    current.variants.append(variant.copy())
                }
            }
            tempList.append(current)
        }
        
        tempList = tempList.sorted(by: { $0.name.compare($1.name) == .orderedAscending})
        products = tempList
        updateCollectionView.reloadData()
    }
    
    private func dispatchProduct(product: Product) -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.productRef.document(product.id).updateData([
                "available": Int(product.available),
                "variants": product.variants.toJSON()
            ]) { err in
                if let err = err {
                    print("Updated Product is error: \(err)")
                    resolve(false)
                } else {
                    print("Updated Product is completed")
                    resolve(true)
                }
            }
        }
    }
    
    private func dispatchProducts(products: [Product]) -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            var count = 0
            for i in products {
                self.dispatchProduct(product: i).then { (_) in
                    count += 1
                    if count == products.count {
                        resolve(true)
                    } else if count > products.count {
                        resolve(false)
                    }
                }
            }
        }
    }
    
    func dispatchUpdateProducts() {
        alertController = displaySpinner(title: "Updating...")
        var tempList: [Product] = []
        for i in cachedProducts {
            let current = i.copy()
            if let product = products.first(where: {$0.id == i.id}) {
                for (index, element) in current.variants.enumerated() {
                    if let variant = product.variants.first(where: {$0.color == element.color && $0.size == element.size}) {
                        current.variants[index] = variant
                    }
                }
            }
            for j in current.variants {
                let available = j.quantity
                j.available = available! - j.reserve
            }
            let total = current.variants.map({ $0.available }).reduce(0, +)
            current.available = total
            tempList.append(current)
        }
        
        let controller = previousController as! ReservedProductController
        
        dispatchProducts(products: tempList).then { (check) in
            self.alertController.dismiss(animated: true) {
                if check {
                    controller.setCachedProducts(records: tempList)
                    self.alertHelper.showAlert(title: "Notice", alert: "Your products have been updated!🧐", controller: self)
                } else {
                    self.alertHelper.showAlert(title: "Notice", alert: "Oops😢 something is wrong!", controller: self)
                }
            }
        }
        
//        let productsJson = Mapper().toJSONString(tempList, prettyPrint: true)!
//        print("\nProducts: \(productsJson)")
    }
    
    private func initialView() {
        let view = UpdateProductView(frame: self.view.frame)
        self.updateCollectionView = view.updateCollectionView
        self.view = view
    }
    
    private func initialCollectionView() {
        updateCollectionView.delegate = self
        updateCollectionView.dataSource = self
        updateCollectionView.register(UpdateProductCell.self, forCellWithReuseIdentifier: updateProductCell)
    }
    
    private func initiateFirestore() {
        productRef = db.collection("products")
    }
    
    @IBAction func handleConfirm(_ sender: Any?) {
        alertHelper.alertUpdate(controller: self)
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func setupNavItems() {
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

}

extension UpdateProductController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let total = products[indexPath.item].variants.count
        let width = view.frame.width
        let height = (120 * total) + (5 * total)
        return CGSize(width: width, height: CGFloat(CGFloat(height) + width))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: updateProductCell, for: indexPath) as! UpdateProductCell
        cell.product = products[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    func onChangeVariant(delegatedFrom cell: UpdateProductCell, variants: [Variant]) {
        guard let indexPath = updateCollectionView.indexPath(for: cell) else { return }
        products[indexPath.item].variants = variants
    }    
}
