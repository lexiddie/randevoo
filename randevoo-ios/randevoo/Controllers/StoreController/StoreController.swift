//
//  StoreController.swift
//  randevoo
//
//  Created by Lex on 28/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON
import FirebaseAuth
import FirebaseFirestore
import Hydra

class StoreController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, StoreProfileCellDelegate {

    var storeId: String!
    
    private var storeAccount: StoreAccount?
    private var mainSiteUrl: String! = ""
    
    private let storeProfileCell = "storeProfileCell"
    private let storeAboutCell = "storeAboutCell"
    private let productFlexCell = "productFlexCell"
    private var productCollectionCell = "productCollectionCell"
    
    private let alert = AlertHelper()
    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
    private var businessRef: CollectionReference!
    private var bizInfoRef: CollectionReference!
    private var bizPeriodRef: CollectionReference!
    private var productRef: CollectionReference!
    private var messagesProvider = MessagesProvider()
    private var messenger: Messenger!
    private let firebaseAuth = Auth.auth()
    private var alertController: UIAlertController!
    private var storeInfo: BizInfo!
    private var storePeriod: BizPeriod!

    var products: [ListProduct] = []
    var collections: [String] = []
    
    var isListingCell: Bool = true
    var isCollectionCell: Bool = false
    var isAboutCell: Bool = false
    
    private var refreshControl = UIRefreshControl()
    private var storeCollectionView: UICollectionView!
    private var friendlyLabel: UILabel!
    private var titleLabel: UILabel!
    
    var storeProductController: ProductDetailController!
    var storeNavController: UINavigationController!
    
    func didChangeToListingView() {
        isListingCell = true
        isCollectionCell = false
        isAboutCell = false
        fetchSelection()
    }
    
    func didChangeToCollectionView() {
        isListingCell = false
        isCollectionCell = true
        isAboutCell = false
        fetchSelection()
    }
    
    func didChangeToAboutView() {
        isListingCell = false
        isCollectionCell = false
        isAboutCell = true
        fetchSelection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems();
        initialView()
        initialCollectionView()
        initiateFirestore()
        fetchStoreAccount()
        loadController()
    }
    
    func loadController() {
        storeProductController = ProductDetailController()
        storeNavController = UINavigationController(rootViewController: storeProductController)
        storeNavController.modalPresentationStyle = .fullScreen
        storeNavController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        storeNavController.navigationBar.shadowImage = UIImage()
        storeNavController.navigationBar.isTranslucent = true
        storeNavController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        storeNavController.view.backgroundColor = UIColor.randevoo.mainLight
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func initiateFirestore() {
        businessRef = db.collection("businesses")
        bizInfoRef = db.collection("bizInfos")
        bizPeriodRef = db.collection("bizPeriods")
        productRef = db.collection("products")
    }
    
    private func fetchStoreAccount() {
        businessRef.document(storeId).getDocument { (document, error) in
            if let document = document, document.exists {
                let result = Mapper<StoreAccount>().map(JSONObject: document.data())!
                self.storeAccount = result
                self.fetchSelection()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func fetchBizInfo() {
        guard let store = storeAccount else { return }
        bizInfoRef
            .whereField("businessId", isEqualTo: (store.id)!)
            .limit(to: 1)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    self.alertController.dismiss(animated: true, completion: nil)
                } else {
                    for document in querySnapshot!.documents {
                        let bizInfo = Mapper<BizInfo>().map(JSONObject: document.data())!
                        self.storeInfo = bizInfo
                    }
                }
            }
    }
    
    private func fetchListProducts() {
        guard let store = storeAccount else { return }
        productRef
            .whereField("businessId", isEqualTo: (store.id)!)
            .whereField("isActive", isEqualTo: true)
            .whereField("isAvailable", isEqualTo: true)
            .whereField("isBanned", isEqualTo: false)
            .order(by: "createdAt", descending: true)
            .limit(to: 200)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    self.refreshControl.endRefreshing()
                } else {
                    var tempList: [ListProduct] = []
                    for document in querySnapshot!.documents {
                        let product = Mapper<Product>().map(JSONObject: document.data())!
                        let subcategory = gSubcategories.filter({$0.id == product.subcategoryId})
                        if subcategory.count != 0 {
                            let listProduct = ListProduct(id: product.id, businessId: product.businessId, name: product.name, price: product.price, category: subcategory[0].category.name, subcategory: subcategory[0].name, photoUrl: product.photoUrls[0])
                            tempList.append(listProduct)
                        } else {
                            let listProduct = ListProduct(id: product.id, businessId: product.businessId, name: product.name, price: product.price, category: "", subcategory: "", photoUrl: product.photoUrls[0])
                            tempList.append(listProduct)
                        }
                    }
                    self.products = tempList
                    self.storeCollectionView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.loadFriendlyLabel()
                }
            }
    }
    
    private func updateProfile() {
        guard let store = storeAccount else { return }
        if store.website != "" {
            mainSiteUrl = storeAccount?.website
        }
        
        titleLabel = UILabel()
        titleLabel.text = store.username
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
    }
    
    private func initialView() {
        let view = StoreView(frame: self.view.frame)
        self.storeCollectionView = view.storeCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.view = view
    }
    
    private func initialCollectionView() {
        storeCollectionView.delegate = self
        storeCollectionView.dataSource = self
        storeCollectionView.register(StoreProfileCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: storeProfileCell)
        storeCollectionView.register(StoreAboutCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: storeAboutCell)
        storeCollectionView.register(ProductFlexCell.self, forCellWithReuseIdentifier: productFlexCell)
        storeCollectionView.register(ProductCollectionCell.self, forCellWithReuseIdentifier: productCollectionCell)
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: UIControl.Event.valueChanged)
        storeCollectionView.addSubview(refreshControl)
    }
    
    private func fetchSelection() {
        updateProfile()
        fetchBizInfo()
        loadFriendlyLabel()
        refreshControl.endRefreshing()
        storeCollectionView.reloadData()
        if isListingCell {
            fetchListProducts()
        } else if isCollectionCell {
            
        }
    }
    
    private func getAccountId() -> String {
        if isPersonalAccount {
            guard let personal = personalAccount else { return "" }
            return personal.id
        } else {
            guard let business = businessAccount else { return "" }
            return business.id
        }
    }
    
    private func loadFriendlyLabel() {
        if isListingCell && products.count == 0 {
            friendlyLabel.text = "No products to show🚀😬"
        } else if isCollectionCell && collections.count == 0 {
            friendlyLabel.text = "No collections to show🚀😬"
        } else {
            friendlyLabel.text = nil
        }
    }
    
    @IBAction func refreshList(_ sender: Any?) {
        fetchSelection()
    }
    
    @IBAction func handleEditProfile(_ sender: Any?) {
//        let controller = EditBizProfileController()
//        controller.businessAccount = storeAccount
//        let navController = UINavigationController(rootViewController: controller)
//        navController.isNavigationBarHidden = false
//        navController.navigationBar.shadowImage = UIImage()
//        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navController.navigationBar.isTranslucent = true
//        navController.navigationBar.barTintColor = UIColor.randevoo.mainLight
//        navController.navigationBar.isOpaque = false
//        navController.modalPresentationStyle = .fullScreen
//        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func handleSite(_ sender: Any?) {
        guard let url = URL(string: "https://\(String(mainSiteUrl))") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func handlePhone(_ sender: Any?) {
        if storeInfo.phoneNumber != "" {
            guard let number = URL(string: "tel://\(String(self.storeInfo.phoneNumber))" ) else { return }
            UIApplication.shared.open(number)
        }
    }
    
    @IBAction func handleEmail(_ sender: Any?) {
        if storeInfo.email != "" {
            guard let email = URL(string: "mailto:\(String(self.storeInfo.email))" ) else { return }
            UIApplication.shared.open(email)
        }
    }
    
    @IBAction func handleMap(_ sender: Any?) {
//        guard let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(String(self.bizInfo.geoPoint.lat)),\(String(self.bizInfo.geoPoint.long))") else { return }
//        UIApplication.shared.open(url)
        
        let controller = StoreMapController()
        controller.storeAccount = storeAccount
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleMessage(_ sender: Any?) {
        let accountId = getAccountId()
        messagesProvider.checkMessenger(accountId: accountId, memberId: self.storeId).then { (check) in
            if check {
                self.messenger = self.messagesProvider.messenger
                let json = Mapper().toJSONString(self.messenger, prettyPrint: true)!
                print("Member is existed, : \(json)")
                self.pushMessageController(messenger: self.messenger)
            } else {
                self.messagesProvider.createMessenger(accountId: accountId, memberId: self.storeId).then { (messenger) in
                    self.messenger = messenger
                    let json = Mapper().toJSONString(messenger, prettyPrint: true)!
                    print("Messenger is created, : \(json)")
                    self.pushMessageController(messenger: messenger)
                }
            }
        }
    }
    
    private func pushMessageController(messenger: Messenger) {
        let controller = MessageController()
        controller.messenger = messenger
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func enableMessage() {
        if isPersonalAccount {
            let messageBarButton = UIBarButtonItem(image: UIImage(named: "MessageIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMessage(_:)))
            navigationItem.rightBarButtonItem = messageBarButton
        }
    }
    
    private func setupNavItems() {
        enableMessage()
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "ArrowLeft")!.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentHorizontalAlignment = .center
        backButton.contentVerticalAlignment = .center
        backButton.contentMode = .scaleAspectFit
        backButton.backgroundColor = UIColor.clear
        backButton.layer.cornerRadius = 8
        backButton.addTarget(self, action: #selector(handleBack(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.snp.makeConstraints{ (make) in
           make.height.width.equalTo(40)
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

}

extension StoreController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: storeProfileCell, for: indexPath) as! StoreProfileCell
            header.store = self.storeAccount
            header.delegate = self
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: storeAboutCell, for: indexPath) as! StoreAboutCell
            footer.storeInfo = self.storeInfo
            if !isAboutCell {
                footer.isHidden = true
            } else {
                footer.isHidden = false
            }
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        guard let store = storeAccount else { return CGSize(width: width, height: width) }
        let font = UIFont(name: "Quicksand-Medium", size: 17)!
        let bioWidth = view.frame.width - 40
        var heightOfText = 0.0 as Float
        if store.bio != "" {
            heightOfText = Float(store.bio.heightWithConstrainedWidth(width: bioWidth, font: font))
        }
        var currentHeight: Float = 265
        if store.website != "" {
            currentHeight += 25
        }
        return CGSize(width: width, height: CGFloat(currentHeight + heightOfText) + 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if !isAboutCell {
            return CGSize(width: view.frame.width, height: 0)
        } else {
            return CGSize(width: view.frame.width, height: 1200)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isListingCell {
            let width = (view.frame.width - 2) / 2
            return CGSize(width: width, height: width)
        } else if isCollectionCell {
            let width = view.frame.width - 2
            return CGSize(width: width, height: width / 2)
        } else {
            let width = view.frame.width
            return CGSize(width: width, height: width)
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
        if isListingCell {
            return products.count
        } else if isCollectionCell {
            return collections.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isCollectionCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productFlexCell, for: indexPath) as! ProductCollectionCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productFlexCell, for: indexPath) as! ProductFlexCell
            cell.product = products[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dispatchLoadController(productId: products[indexPath.item].id)
    }
    
    private func dispatchLoadController(productId: String) {
        storeProductController.productId = productId
        storeProductController.isFromSave = false
        storeProductController.loadUpdate()
        self.navigationController?.present(storeNavController, animated: true, completion: nil)
    }
}
