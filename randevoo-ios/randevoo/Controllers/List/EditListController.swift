//
//  EditListController.swift
//  randevoo
//
//  Created by Xell on 4/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON
import SwiftGifOrigin
import Cache
import ObjectMapper
import Hydra
import FirebaseFirestore

class EditListController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EditListTextDelegate {

    var productImg: UIImageView!
    var ProductNameLabel: UILabel!
    var mainCollectionView: UICollectionView!
    let sizeCell = "AddToListSizeCell"
    let colorCell = "AddToListColorCell"
    let headerID = "AddToListCollectionHeader"
    let footerID = "AddToListCollectionFooter"
    var color = ""
    var previousColor = ""
    var size = ""
    var previousSize = ""
    var amount = 1
    var previousAmount = 1
    var maxAmount = 0
    var personalAccount: PersonalAccount!
    var businessAccount: BusinessAccount!
    let alertHelper = AlertHelper()
    var currentProduct: Product!
    var currentSizes: [SizeDisplayModel] = []
    var currentColors: [ColorDisplayModel] = []
    var updateSizes: [SizeDisplayModel] = []
    var section = 0
    var row = 0
    var isFirstLoad = false
    var list: ListModel!
    let db = Firestore.firestore()
    var previousController: UIViewController!
    var seperateList: [[DisplayList]] = []
    
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
        let view = EditListView(frame: self.view.frame)
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
        mainCollectionView.register(EditListSizeCollectionCell.self, forCellWithReuseIdentifier: sizeCell)
        mainCollectionView.register(EditListColorCollectionCell.self, forCellWithReuseIdentifier: colorCell)
        mainCollectionView.register(EditListCollectionFooterCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerID)
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
    
    private func getInformation(){
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
            for c in filterColor {
                if c.available > 0 {
                    isAvailable = true
                    break
                }
            }
            currentColors.append(ColorDisplayModel(color: color, isAvailable: isAvailable))
        }
        self.mainCollectionView.reloadData()
    }
    
    @IBAction func editListDone(_ sender: Any?) {
        if size == "" {
            alertHelper.showAlert(title: "Size Empty", alert: "Please Choose Any Size", controller: self)
        } else if color == "" {
            alertHelper.showAlert(title: "Color Empty", alert: "Please Choose Any Color", controller: self)
        } else if personalAccount == nil {
            alertHelper.showAlert(title: "Login", alert: "Please Login to Add to List", controller: self)
        } else {
            if size == previousSize && color == previousColor && amount == previousAmount {
                self.dismiss(animated: true, completion: nil)
            } else {
                print("run this")
                let genID = list.id!
                let currentList: ListModel
                let (newId, newAmount, isFound) = ifProductExistInDb(productId: currentProduct.id, size: size, color: color)
                if isFound {
                    currentList = ListModel(id: newId, userId: personalAccount.id, productId: currentProduct.id, variant: Variant(color: color, size: size, quantity: newAmount + amount))
                    var listId:[String] = []
                    listId.append(genID)
                    AddToListHelper().deleteProductFromList(ids: listId)
                } else {
                    currentList = ListModel(id: genID, userId: personalAccount.id, productId: currentProduct.id, variant: Variant(color: color, size: size, quantity: amount))
                }
                let alertView = alertHelper.displayCreateNewProductAlert(msg: " Update List ... ", controller: self)
                let addToListHelper = AddToListHelper()
                let _ = async({ _ -> Bool in
                    let status = try await(addToListHelper.addProductToList(list: currentList))
                    return status
                }).then({ status in
                    print(status)
                    if status {
                        alertView.dismiss(animated: true, completion: { [self] in
                            alertHelper.showAlertForUpdateList(title: "Update List", alert: "Successfully update the list", controller: self, previousController: previousController, personalAcc: personalAccount.id)
                        })
                    } else {
                        alertView.dismiss(animated: true, completion: {
                            self.alertHelper.showAlertForUpdateListForNoAction(title: "Update List", alert: "Fail to update the list", controller: self)
                        })
                    }
                })
            }
        }
    }
    
    private func ifProductExistInDb(productId: String, size: String, color: String) -> (String, Int, Bool) {
        var id = ""
        var amount = 0
        var isFound = false
        for i in 0...seperateList.count - 1 {
            for j in 0...seperateList[i].count - 1 {
                if seperateList[i][j].product.id == productId &&
                    seperateList[i][j].information.variant.size == size &&
                    seperateList[i][j].information.variant.color == color &&
                    seperateList[i][j].information.id != list.id{
                    id = seperateList[i][j].information.id
                    amount = seperateList[i][j].information.variant.quantity
                    isFound = true
                    break
                }
            }
            if isFound {
                break
            }
        }
        return (id, amount, isFound)
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
    
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: EditListCollectionFooterCell) {
        let text = String(cell.numberTextField.text!)
        let number = Int(text)
        if number != nil && number! <= maxAmount{
            amount = number!
        }
    }
    
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: EditListCollectionFooterCell) -> Bool {
        //        print("Validation action in textField from cell: \(String(describing: mainCollectionView.indexPath(for: cell)))")
                return true
    }

}

extension EditListController {
    
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
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerID, for: indexPath) as! EditListCollectionFooterCell
            footer.delegate = self
            footer.controller = self
            footer.numberTextField.text = String(amount)
            print(maxAmount)
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCell, for: indexPath) as! EditListColorCollectionCell
            cell.mainController = self
            cell.titleLabel.text = "Color"
            cell.colorArray  = currentColors
            cell.currentProduct = currentProduct
            if color != "" {
                cell.selectedColor = color
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sizeCell, for: indexPath) as! EditListSizeCollectionCell
            cell.mainController = self
            cell.titleLabel.text = "Size"
            if isFirstLoad {
                if color  != "" {
                    cell.sizeArray = setupSizeArray(color: color)
                } else {
                    cell.sizeArray = currentSizes
                }
                cell.size = size
            } else {
                cell.sizeArray = updateSizes
                cell.sizeCollectionView.reloadData()
            }
            return cell
        }
    }
    
}
