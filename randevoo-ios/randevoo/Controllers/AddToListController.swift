//
//  ExamplePopupViewController.swift
//  BottomPopup
//
//  Created by Emre on 16.09.2018.
//  Copyright © 2018 Emre. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON
import SwiftGifOrigin
import Cache
import ObjectMapper
import Hydra
import FirebaseFirestore

class AddToListController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AddToListTextDelegate {
    
    var productImg: UIImageView!
    var ProductNameLabel: UILabel!
    var mainCollectionView: UICollectionView!
    let sizeCell = "AddToListSizeCell"
    let colorCell = "AddToListColorCell"
    let headerID = "AddToListCollectionHeader"
    let footerID = "AddToListCollectionFooter"
    var color = ""
    var size = ""
    var amount = 1
    var maxAmount = 0
    var personalAccount: PersonalAccount!
    var businessAccount: BusinessAccount!
    let alertHelper = AlertHelper()
    var currentProduct: Product!
    var currentSizes: [SizeDisplayModel] = []
    var currentColors: [ColorDisplayModel] = []
    var updateSizes: [SizeDisplayModel] = []
    var isFirstLoad = true
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        initialView()
        initialCollectionView()
        fetchAccounts()
        getInformation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
    }
                  
    
    private func initialView() {
        let view = AddToListView(frame: self.view.frame)
        mainCollectionView = view.mainCollectionView
        self.view = view
    }
    
    func fetchAccounts() {
        if let personalCache: PersonalAccount = FCache.get("personal"), !FCache.isExpired("personal") {
            self.personalAccount = personalCache
            let personalJson = Mapper().toJSONString(personalCache, prettyPrint: true)!
            print("\nRetrieved Cache Personal at AddToListController: \(personalJson)")
            if let businessCache: BusinessAccount = FCache.get("business"), !FCache.isExpired("business") {
                self.businessAccount = businessCache
                let businessJson = Mapper().toJSONString(businessCache, prettyPrint: true)!
                print("\nRetrieved Cache BizInfo at AddToListController: \(businessJson)")
            }
        }
    }
    
    private func initialCollectionView() {
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(AddToListCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID)
        mainCollectionView.register(AddToListSizeCollectionCell.self, forCellWithReuseIdentifier: sizeCell)
        mainCollectionView.register(AddToListColorCollectionCell.self, forCellWithReuseIdentifier: colorCell)
        mainCollectionView.register(AddToListCollectionFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerID)
    }
    
    func increaseAmount() -> Int {
        if amount < maxAmount {
            amount += 1
        }
        return amount
    }
    
    func decreaseAmount() -> Int {
        if amount > 1 {
            amount -= 1
        }
        return amount
    }
    
    private func getInformation() {
        guard let product = currentProduct else { return }
        var uniqueColor: [String] = []
        for variant in product.variants {
            if !uniqueColor.contains(variant.color) {
                uniqueColor.append(variant.color)
            }
        }
        for color in uniqueColor {
            var isAvailable = false
            let filterColor = product.variants.filter({$0.color == color})
            print(filterColor.count)
            for c in filterColor {
                setupSize(color: c.color)
                if c.available > 0 {
                    isAvailable = true
                    break
                }
            }
            currentColors.append(ColorDisplayModel(color: color, isAvailable: isAvailable))
        }
        self.mainCollectionView.reloadData()
    }
    
    private func setupSize(color: String) {
        guard let product = currentProduct else { return }
        let filterInfo = product.variants.filter({$0.color == color})
        print(filterInfo.count)
        for info in filterInfo {
            if !currentSizes.contains(where: {$0.size == info.size}) {
                if info.available > 0 {
                    currentSizes.append(SizeDisplayModel(size: info.size, isAvailable: true))
                } else {
                    print("this is current size when false \(currentSizes.count)")
                    currentSizes.append(SizeDisplayModel(size: info.size, isAvailable: false))
                }
            } else {
                let index = currentSizes.firstIndex(where: { $0.size == info.size })!
                if info.available > 0 {
                    currentSizes[index] = SizeDisplayModel(size: info.size, isAvailable: true)
                } else {
                    currentSizes[index] = SizeDisplayModel(size: info.size, isAvailable: false)
                }
            }
        }
        self.mainCollectionView.reloadData()
    }
    
    @IBAction func addToList(_ sender: Any?) {
        if size == "" {
            alertHelper.showAlert(title: "Size Empty", alert: "Please Choose Any Size", controller: self)
        } else if color == "" {
            alertHelper.showAlert(title: "Color Empty", alert: "Please Choose Any Color", controller: self)
        } else if personalAccount == nil {
            alertHelper.showAlert(title: "Login", alert: "Please Login to Add to List", controller: self)
        } else {
            let prodList = db.collection("bags")
            let genID = prodList.document().documentID
            let currentList = ListModel(id: genID, userId: personalAccount.id, productId: currentProduct.id, variant: Variant(color: color, size: size, quantity: amount))
            let alertView = alertHelper.displayCreateNewProductAlert(msg: "Add Product To List ... ", controller: self)
            let addToListHelper = AddToListHelper()
            let _ = async({ _ -> [ListModel] in
                let existingList = try await(addToListHelper.retrieveSpecificProduct(id: self.currentProduct.id, userId: self.personalAccount.id))
                return existingList
            }).then({ existingList in
                if existingList.count == 0 || !existingList.contains(where: {$0.productId == self.currentProduct.id && $0.variant.size == self.size && $0.variant.color == self.color}) {
                    let _ = async({ _ -> Bool in
                        let status = try await(addToListHelper.addProductToList(list: currentList))
                        return status
                    }).then({ status in
                        print(status)
                        if status {
                            alertView.dismiss(animated: true, completion: { [self] in
                                alertHelper.alertBag(msg: "", controller: self)
                            })
                        } else {
                            alertView.dismiss(animated: true, completion: {
                                self.alertHelper.showAlert(title: "Add To List", alert: "Fail to add Product to Personal List", controller: self)
                            })
                        }
                        
                    })
                } else if existingList.contains(where: {$0.productId == self.currentProduct.id && $0.variant.size == self.size && $0.variant.color == self.color}){
                    let filterList = existingList.filter({$0.productId == self.currentProduct.id && $0.variant.size == self.size && $0.variant.color == self.color})
                    let newAmount = self.amount +  filterList[0].variant.quantity
                    let newCurrentList = ListModel(id: filterList[0].id, userId: self.personalAccount.id, productId: self.currentProduct.id, variant: Variant(color: self.color, size: self.size, quantity: newAmount))
                    let _ = async({ _ -> Bool in
                        let status = try await(addToListHelper.addProductToList(list: newCurrentList))
                        return status
                    }).then({ status in
                        print(status)
                        if status {
                            alertView.dismiss(animated: true, completion: { [self] in
                                alertHelper.alertBag(msg: "", controller: self)
//                                alertHelper.showAlertForAddToList(title: "Add To List", alert: "Successfully add Product to Personal List", controller: self)
                            })
                        } else {
                            alertView.dismiss(animated: true, completion: {
                                self.alertHelper.showAlert(title: "Add To List", alert: "Fail to add Product to Personal List", controller: self)
                            })
                        }
                        
                    })
                }
                
            })
        }
    }
    
    func dissmissView(){
        dismiss(animated: true, completion: nil)
    }
    
    
    func grabColor(color: String) {
        updateSizes.removeAll()
        isFirstLoad = false
        let variants = currentProduct!.variants.filter({ $0.color == color })
        for info in variants {
            if !updateSizes.contains(where: {$0.size == info.size }) {
                if info.available > 0 {
                    updateSizes.append(SizeDisplayModel(size: info.size, isAvailable: true))
                } else {
                    updateSizes.append(SizeDisplayModel(size: info.size, isAvailable: false))
                }
            }
        }
        if !updateSizes.contains(where: {$0.size == size }) {
            size = ""
        }
        mainCollectionView.reloadData()
    }
    
    func setupSizeArray(color: String) -> [SizeDisplayModel]{
        let variants = currentProduct!.variants.filter({ $0.color == color })
        var sizes: [SizeDisplayModel] = []
        for info in variants {
            if !sizes.contains(where: {$0.size == info.size}) {
                if info.available > 0 {
                    sizes.append(SizeDisplayModel(size: info.size, isAvailable: true))
                } else {
                    sizes.append(SizeDisplayModel(size: info.size, isAvailable: false))
                }
            }
        }
        return sizes
    }
    
    func setupMaxAmount () {
        amount = 1
        if size != "" && color != "" {
            let amount = currentProduct.variants.filter({$0.color == color && $0.size == size})
            if amount.count != 0 {
                maxAmount = amount[0].available
                mainCollectionView.reloadData()
            }
        }
    }
    
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: AddToListCollectionFooter) {
        let text = String(cell.numberTextField.text!)
        let number = Int(text)
        if number != nil && number! <= maxAmount{
            amount = number!
        }
    }
    
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: AddToListCollectionFooter) -> Bool {
//        print("Validation action in textField from cell: \(String(describing: mainCollectionView.indexPath(for: cell)))")
        return true
    }

}

extension AddToListController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! AddToListCollectionHeader
            header.ProductImg.loadCacheImage(urlString: currentProduct.photoUrls[0])
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let priceFormat = numberFormatter.string(from: NSNumber(value: currentProduct.price))
            header.productNameLabel.text = currentProduct.name
            header.productPriceLabel.text = "฿\(String(priceFormat!))"
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerID, for: indexPath) as! AddToListCollectionFooter
            footer.delegate = self
            footer.controller = self
            footer.numberTextField.text = String(amount)
            if amount <= 1 {
                footer.decreaseButton.isEnabled = false
                footer.tintColor = UIColor.lightGray
            } else {
                footer.decreaseButton.isEnabled = true
                footer.tintColor = UIColor.black
            }
            footer.maximum = maxAmount
            footer.enableIncreaseDecrease()
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: view.frame.width, height: 85)
        } else {
            return CGSize(width: view.frame.width, height: 90)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCell, for: indexPath) as! AddToListColorCollectionCell
            cell.mainController = self
            cell.titleLabel.text = "Color"
            cell.colorArray  = currentColors
            cell.currentProduct = currentProduct
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sizeCell, for: indexPath) as! AddToListSizeCollectionCell
            cell.mainController = self
            cell.titleLabel.text = "Size"
            if isFirstLoad {
                cell.sizeArray = currentSizes
            } else {
                cell.sizeArray = updateSizes
                cell.sizeCollectionView.reloadData()
            }
            return cell
        }
    }
    
}

