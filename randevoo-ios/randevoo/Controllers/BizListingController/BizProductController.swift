//
//  BizProductController.swift
//  randevoo
//
//  Created by Lex on 16/3/21.
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
import Presentr

class BizProductController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BizProductInfoCellDelegate, BizProductCellDelegate {

    var product: Product!
    
    private let alertHelper = AlertHelper()
    private let db = Firestore.firestore()
    private var productRef: CollectionReference!
    private var alertController: UIAlertController!
    private var previousHash: String = ""
    
    private var variants: [Variant] = []
    private var subcategory: Subcategory!
    
    private let bizProductSlideCell = "bizProductSlideCell"
    private let bizProductInfoCell = "bizProductInfoCell"
    private let bizProductCell = "bizProductCell"
    private var productCollectionView: UICollectionView!
    private var headerSlide: BizProductSlideCell?
    private var floatingSlide = BizProductSlideCell()
    
    private var isActionable: Bool = true
    
    let presenter: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.fluid(percentage: 0.7)
        let center = ModalCenterPosition.bottomCenter
        let presentr = Presentr(presentationType: .custom(width: width, height: height, center: center))
        presentr.roundCorners = true
        presentr.cornerRadius = 15
        presentr.backgroundColor = UIColor.black
        presentr.backgroundOpacity = 0.7
        presentr.transitionType = .coverVertical
        presentr.dismissTransitionType = .coverVertical
        presentr.dismissOnSwipe = true
        presentr.dismissAnimated = true
        presentr.dismissOnSwipeDirection = .default
        return presentr
    }()
    
    var subcategoryId: String = ""
    var name: String = ""
    var price: String = ""
    var iDescription: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialCollectionView()
        initiateFirestore()
        fetchSelection()
    }

    private func initialView() {
        let view = BizProductView(frame: self.view.frame)
        self.productCollectionView = view.productCollectionView
        self.view = view
    }
    
    private func initiateFirestore() {
        productRef = db.collection("products")
    }
    
    private func initialCollectionView() {
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        productCollectionView.register(BizProductSlideCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: bizProductSlideCell)
        productCollectionView.register(BizProductInfoCell.self, forCellWithReuseIdentifier: bizProductInfoCell)
        productCollectionView.register(BizProductCell.self, forCellWithReuseIdentifier: bizProductCell)
        productCollectionView.keyboardDismissMode = .onDrag
    }
    
    private func loadSubcategory() {
        if let record = gSubcategories.first(where: {$0.id == product.subcategoryId}) {
            subcategory = record
            product.subcategory = record
        }
    }
    
    private func loadReserves() {
        variants = product.getVariants()
        for i in variants {
            let reserve = i.quantity - i.available
            i.reserve = reserve
            i.isDeletable = reserve == 0 ? true : false
        }
        
        for j in variants {
            let reserve = j.quantity - j.available
            if reserve != 0 {
                isActionable = false
                return
            }
        }
    }
    
    func appendVariant(variant: Variant) {
        for (index, element) in variants.enumerated() {
            if element.color == variant.color && element.size == variant.size {
                element.quantity += variant.quantity
                element.available += variant.available
            } else if index == variants.count - 1 {
                variants.append(variant)
            }
        }
        productCollectionView.reloadData()
    }
    
    private func fetchSelection() {
        previousHash = product.hashDataObject()
        loadSubcategory()
        loadReserves()
        productCollectionView.reloadData()
    }
    
    func removeVariant(selection: Int) {
        let current = variants[selection]
        if variants.count == 1 {
            alertHelper.showAlert(title: "Notice", alert: "You cannot delete this last variant of product!", controller: self)
        } else if current.isDeletable {
            variants.remove(at: selection)
            productCollectionView.reloadData()
        } else {
            alertHelper.showAlert(title: "Notice", alert: "You cannot delete variant with reserved quantity!", controller: self)
        }
    }
    
    private func assignAvailable() {
        for i in variants {
            let available = i.quantity
            i.available = available! - i.reserve
        }
        let total = variants.map({ $0.available }).reduce(0, +)
        product.variants = variants
        product.available = total
    }
    
    private func assignData() {
        if !name.isEmpty && name != "" {
            product.name = name
        }
        if !price.isEmpty && price != "" {
            product.price = Double(price)
        }
        if !iDescription.isEmpty && iDescription != "" {
            product.description = iDescription
        }
    }
    
    private func dispatchProduct() -> Promise<Bool> {
        alertController = displaySpinner(title: "Processing...")
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.productRef.document(self.product.id).updateData(self.product.toJSON()) { err in
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
    
    func updateProduct() {
        assignAvailable()
        assignData()
        let current = product.hashDataObject()
        if previousHash == current {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            dispatchProduct().then { (check) in
                self.alertController.dismiss(animated: true) {
                    if check {
                        self.previousHash = self.product.hashDataObject()
                        self.alertHelper.showAlert(title: "Notice", alert: "Your product has been updated!🧐", controller: self)
                    } else {
                        self.alertHelper.showAlert(title: "Notice", alert: "Oops😢 something is wrong!", controller: self)
                    }
                }
            }
        }
    }
    
    func updatePhoto() {
        
    }
    
    func requestDeleteProduct() {
        alertHelper.alertDeleteProduct(controller: self)
    }
    
    func deletingProduct() {
        if !isActionable {
            self.alertHelper.showAlert(title: "Notice", alert: "You cannot delete reserved product!🙄", controller: self)
        } else {
            alertController = displaySpinner(title: "Deleting...")
            deleteProduct().then { (check) in
                self.alertController.dismiss(animated: true) {
                    if check {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.alertHelper.showAlert(title: "Notice", alert: "You have failed to delete product.", controller: self)
                    }
                }
            }
        }
    }
    
    private func deleteProduct() -> Promise<Bool>{
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let product = self.product else {
                resolve(false)
                return
            }
            self.productRef.document(product.id).updateData([
                "isActive": false
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    resolve(false)
                } else {
                    print("Product is deleted successfully!")
                    resolve(true)
                }
            }
        }
    }
    
    func enablingProduct() {
        alertController = displaySpinner(title: "Processing...")
        enableProduct().then { (check) in
            self.alertController.dismiss(animated: true) {
                if check {
                    self.product.isAvailable = true
                    self.productCollectionView.reloadData()
                    self.alertHelper.showAlert(title: "Notice", alert: "You have enabled product successfully", controller: self)
                } else {
                    self.alertHelper.showAlert(title: "Notice", alert: "You have failed to enable product.", controller: self)
                }
            }
        }
    }
    
    func disablingProduct() {
        if !isActionable {
            self.alertHelper.showAlert(title: "Notice", alert: "You cannot disable reserved product!🙄", controller: self)
        } else {
            alertController = displaySpinner(title: "Processing...")
            disableProduct().then { (check) in
                self.alertController.dismiss(animated: true) {
                    if check {
                        self.product.isAvailable = false
                        self.productCollectionView.reloadData()
                        self.alertHelper.showAlert(title: "Notice", alert: "You have disabled product successfully", controller: self)
                    } else {
                        self.alertHelper.showAlert(title: "Notice", alert: "You have failed to disable product.", controller: self)
                    }
                }
            }
        }
    }
    
    private func disableProduct() -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let product = self.product else {
                resolve(false)
                return
            }
            self.productRef.document(product.id).updateData([
                "isAvailable": false
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    resolve(false)
                } else {
                    print("Product is disable successfully!")
                    resolve(true)
                }
            }
        }
    }
    
    private func enableProduct() -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let product = self.product else {
                resolve(false)
                return
            }
            self.productRef.document(product.id).updateData([
                "isAvailable": true
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    resolve(false)
                } else {
                    print("Product is enabled successfully!")
                    resolve(true)
                }
            }
        }
    }
    
    @IBAction func handleAction(_ sender: Any?) {
        guard let product = self.product else { return }
        alertHelper.alertBizProduct(controller: self, product: product)
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleAdd(_ sender: Any?) {
        let controller = BizVariationController()
        controller.previousController = self
        controller.subcategory = subcategory
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = false
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navController.modalPresentationStyle = .fullScreen
        customPresentViewController(presenter, viewController: navController, animated: true, completion: nil)
    }
    
    private func setupNavItems() {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "ArrowLeft")!.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentHorizontalAlignment = .center
        backButton.contentVerticalAlignment = .center
        backButton.contentMode = .scaleAspectFit
        backButton.backgroundColor = UIColor.white
        backButton.layer.cornerRadius = 8
        backButton.addTarget(self, action: #selector(handleBack(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.snp.makeConstraints{ (make) in
            make.height.width.equalTo(40)
        }
        
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(named: "AddingIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        addButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        addButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        addButton.contentHorizontalAlignment = .center
        addButton.contentVerticalAlignment = .center
        addButton.contentMode = .scaleAspectFit
        addButton.backgroundColor = UIColor.white
        addButton.layer.cornerRadius = 8
        addButton.addTarget(self, action: #selector(handleAdd(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        addButton.snp.makeConstraints{ (make) in
            make.height.width.equalTo(40)
        }
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension BizProductController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: bizProductSlideCell, for: indexPath) as! BizProductSlideCell
        header.slidePhotos = product.photoUrls
        header.isDisable = !product.isAvailable
        headerSlide = header
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        if indexPath.row == 0 {
            return CGSize(width: width, height: 555)
        } else {
            return CGSize(width: width, height: 120)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return variants.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bizProductInfoCell, for: indexPath) as! BizProductInfoCell
            cell.product = product
            cell.delegate = self
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bizProductCell, for: indexPath) as! BizProductCell
        cell.variant = variants[indexPath.item - 1]
        cell.delegate = self
        return cell
    }
    
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: BizProductCell) {
        guard let indexPath = productCollectionView?.indexPath(for: cell) else { return }
        let quantity = variants[indexPath.row - 1].quantity
        let available = variants[indexPath.row - 1].available
        let minimum = quantity! - available!
        let maximum: Int = 100
        let text = String(cell.numberTextField.text!)
        let number = Int(text)
        if number != nil && number! >= minimum && number! <= maximum {
            variants[indexPath.row - 1].quantity = number!
        }
    }
    
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: BizProductCell) -> Bool {
        return true
    }
    
    func plusAmount(delegatedFrom cell: BizProductCell) -> Int {
        guard let indexPath = productCollectionView?.indexPath(for: cell) else { return 0 }
        let quantity = variants[indexPath.row - 1].quantity
        var current: Int = quantity!
        let maximum: Int = 100
        if current < maximum {
            current += 1
            variants[indexPath.row - 1].quantity = current
        }
        return current
    }
    
    func minusAmount(delegatedFrom cell: BizProductCell) -> Int {
        guard let indexPath = productCollectionView?.indexPath(for: cell) else { return 0 }
        let quantity = variants[indexPath.row - 1].quantity
        let available = variants[indexPath.row - 1].available
        let minimum = quantity! - available!
        var current: Int = quantity!
        if current > minimum {
            current -= 1
            variants[indexPath.row - 1].quantity = current
        }
        return current
    }
    
    func deleteVariation(delegatedFrom cell: BizProductCell) {
        guard let indexPath = productCollectionView?.indexPath(for: cell) else { return }
        alertHelper.alertDeleteVariation(controller: self, selection: indexPath.item - 1)
    }
    
    func changeCategory(delegatedFrom cell: BizProductInfoCell) {
        alertHelper.showAlert(title: "Notice", alert: "Category cannot be changed!🥲", controller: self)
    }
    
    func onChangeName(record: String) {
        name = record
    }
    
    func onChangePrice(record: String) {
        price = record
    }
    
    func onChangeDescription(record: String) {
        iDescription = record
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerSlide?.scrollViewDidScroll(scrollView)
        floatingSlide.scrollViewDidScroll(scrollView)
    }
}
