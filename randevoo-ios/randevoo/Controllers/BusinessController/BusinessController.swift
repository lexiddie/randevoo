//
//  BusinessController.swift
//  randevoo
//
//  Created by Lex on 5/12/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import Hydra
import Presentr

class BusinessController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BusinessProfileCellDelegate {

    var mainTabBar: UITabBar!
    var mainSiteUrl: String! = ""
    
    let businessProfileCell = "businessProfileCell"
    let productFlexCell = "productFlexCell"
    var productCollectionCell = "productCollectionCell"
    let bizAboutFlexCell = "bizAboutFlexCell"
    
    private let deviceProvider = DevicesProvider()
    private let switchProvider = SwitchProvider()
    
    private let alert = AlertHelper()
    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
    private var userRef: CollectionReference!
    private var businessRef: CollectionReference!
    private var bizInfoRef: CollectionReference!
    private var bizPeriodRef: CollectionReference!
    private var productRef: CollectionReference!
    private var reservationRef: CollectionReference!
    private let firebaseAuth = Auth.auth()
    private let devicesProvider = DevicesProvider()
    private var alertController: UIAlertController!
    
    var products: [ListProduct] = []
    var collections: [String] = []
    
    var isListingCell: Bool = true
    var isCollectionCell: Bool = false
    var isAboutCell: Bool = false
    
    private var refreshControl = UIRefreshControl()
    private var businessCollectionView: UICollectionView!
    private var friendlyLabel: UILabel!
    private var switchButton = UIButton(type: .system)
    
    private var reservation: Reservation?
    
    private var categoriesProvider = CategoriesProvider()
    
    private var mainTabBarController: MainTabBarController!
    
    let presenter: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.fluid(percentage: 0.60)
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
        initiateFirestore()
        initialCollectionView()
        updateRealtimeAccounts()
        fetchSelection()
        
//        categoriesProvider.dispatchData()
        
        mainTabBarController = (self.tabBarController as! MainTabBarController)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainTabBar.isHidden = false
        
        refreshControl.endRefreshing()
        
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    
    // remove FCM token from ban account
    private func dispatchAutoSwitch() {
        guard let user = personalAccount else { return }
//        let mainTabBarController = self.tabBarController as! MainTabBarController
        deviceProvider.validateDeviceToken(accountId: user.id)
        switchProvider.startSwitchAccount(mainTabBarController: mainTabBarController, accountId: user.id, isPersonal: true)

        mainTabBarController.showBanAlert()
    }
    
    private func removeToken() {
        guard let user = personalAccount else { return }
        guard let fcmToken = Messaging.messaging().fcmToken else { return }
        self.devicesProvider.removeToken(userId: user.id, fcmToken: fcmToken)
    }
    
    private func dispatchSignOut() {
        let initiateSignIn = ["isSignIn": false]
        self.defaults.set(initiateSignIn, forKey: "signIn")
        
//        let mainTabBarController = self.tabBarController as! MainTabBarController
        
        let mainController = MainController()
        mainController.mainTabBarController = mainTabBarController
        
        gMainNavController = UINavigationController(rootViewController: mainController)
        gMainNavController.isNavigationBarHidden = false
        gMainNavController.navigationBar.shadowImage = UIImage()
        gMainNavController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        gMainNavController.navigationBar.isTranslucent = false
        gMainNavController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        gMainNavController.modalPresentationStyle = .fullScreen
        
        do {
            try self.firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        self.removeToken()
        
        // Remove all objects
        try? storage!.removeAll()
        
        // Remove expired objects
        try? storage!.removeExpiredObjects()
        
        mainTabBarController.setupTabBar()
        mainTabBarController.selectedIndex = 0
        mainTabBarController.present(gMainNavController, animated: true, completion: nil)
    }
    
    private func initiateFirestore() {
        userRef = db.collection("users")
        businessRef = db.collection("businesses")
        bizInfoRef = db.collection("bizInfos")
        bizPeriodRef = db.collection("bizPeriods")
        productRef = db.collection("products")
        reservationRef = db.collection("reservations")
    }
    
    private func fetchProducts() {
        guard let business = businessAccount else { return }
        productRef
            .whereField("businessId", isEqualTo: (business.id)!)
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
                    self.businessCollectionView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.loadFriendlyLabel()
                }
            }
    }
    
    private func updateProfile() {
        guard let business = businessAccount else { return }
        if business.website != "" {
            mainSiteUrl = businessAccount?.website
        }
        reloadUsername()
        businessCollectionView.reloadData()
    }
    
    func fetchAccounts() {
        if let personalCache: PersonalAccount = FCache.get("personal"), !FCache.isExpired("personal") {
            personalAccount = personalCache
            let personalJson = Mapper().toJSONString(personalCache, prettyPrint: true)!
            print("\nRetrieved Cache Personal at BusinessController: \(personalJson)")
            if let businessCache: BusinessAccount = FCache.get("business"), !FCache.isExpired("business") {
                businessAccount = businessCache
                let businessJson = Mapper().toJSONString(businessCache, prettyPrint: true)!
                print("\nRetrieved Cache Business at BusinessController: \(businessJson)")
            }
        }
    }
    
    private func updateRealtimeAccounts() {
        fetchAccounts()
        fetchBizPeriod().then { (_) in }
        fetchBizInfo().then { (_) in }
        let mainTabBarController = self.tabBarController as! MainTabBarController
        mainTabBar = mainTabBarController.tabBar
        if !isSignIn {
            print("The running app is not sign in!")
            return
        }
        if !isPersonalAccount {
            fetchBusinessAccountData().then { (result) in
                if result {
                    print("Business Data has been fetched successfully, Realtime")
                }
            }
        }
        
        fetchPersonalAccountData().then { (result) in
            if result {
                print("Personal Data has been fetched successfully, Realtime")
            }
        }
    }
    
    private func fetchPersonalAccountData() -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let personal = personalAccount else {
                print("Personal Info is empty")
                resolve(false)
                return
            }
            userListener = self.userRef.document(personal.id).addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching personal document: \(error!)")
                    resolve(false)
                    return
                }
                guard let data = document.data() else {
                    print("Personal Document data was empty.")
                    resolve(false)
                    return
                }
                let record = Mapper<PersonalAccount>().map(JSONObject: data)!
                personalAccount = record
                
                if (record.isBanned) {
                    self.dispatchSignOut()
                }
                
                FCache.set(personalAccount, key: "personal")
                print("Added Personal Account Into Cache")
                let userJson = Mapper().toJSONString(personalAccount!, prettyPrint: true)!
                print("Personal Account Biz: \(userJson)")
                resolve(true)
            }
        }
    }
    
    private func fetchBizPeriod() -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let business = businessAccount else {
                resolve(false)
                return
            }
            self.bizPeriodRef
                .whereField("businessId", isEqualTo: (business.id)!)
                .limit(to: 1)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        resolve(false)
                    } else {
                        for document in querySnapshot!.documents {
                            let record = Mapper<BizPeriod>().map(JSONObject: document.data())!
                            gBizPeriod = record
                            resolve(true)
                        }
                    }
                }
        }
    }
    
    private func fetchBizInfo() -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let business = businessAccount else {
                resolve(false)
                return
            }
            self.bizInfoRef
                .whereField("businessId", isEqualTo: (business.id)!)
                .limit(to: 1)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        resolve(false)
                    } else {
                        for document in querySnapshot!.documents {
                            let record = Mapper<BizInfo>().map(JSONObject: document.data())!
                            gBizInfo = record
                            resolve(true)
                        }
                    }
                }
        }
    }
    
    private func fetchBusinessAccountData() -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let business = businessAccount else {
                print("Business Info is empty")
                resolve(false)
                return
            }
            businessListener = self.businessRef.document(business.id).addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching business document: \(error!)")
                    resolve(false)
                    return
                }
                guard let data = document.data() else {
                    print("Business Document data was empty.")
                    resolve(false)
                    return
                }
                let record = Mapper<BusinessAccount>().map(JSONObject: data)!
                businessAccount = record
                
                if (record.isBanned) {
                    self.dispatchAutoSwitch()
                }
                
                self.updateProfile()
                FCache.set(businessAccount, key: "business")
                print("Added Business Account Into Cache")
                let businessJson = Mapper().toJSONString(businessAccount!, prettyPrint: true)!
                print("Business Account: \(businessJson)")
                resolve(true)
            }
        }
    }

    private func initialView() {
        let view = BusinessView(frame: self.view.frame)
        self.businessCollectionView = view.businessCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.view = view
    }
    
    private func initialCollectionView() {
        businessCollectionView.delegate = self
        businessCollectionView.dataSource = self
        businessCollectionView.register(BusinessProfileCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: businessProfileCell)
        businessCollectionView.register(BizAboutFlexCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: bizAboutFlexCell)
        businessCollectionView.register(ProductFlexCell.self, forCellWithReuseIdentifier: productFlexCell)
        businessCollectionView.register(ProductCollectionCell.self, forCellWithReuseIdentifier: productCollectionCell)
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: UIControl.Event.valueChanged)
        businessCollectionView.addSubview(refreshControl)
    }
    
    private func fetchSelection() {
        loadFriendlyLabel()
        refreshControl.endRefreshing()
        businessCollectionView.reloadData()
        if isListingCell {
            fetchProducts()
        } else if isCollectionCell {
            
        } else if isAboutCell {
            
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
        guard let business = businessAccount else { return }
        let controller = EditBizProfileController()
        controller.business = business.copy()
        
//        let navController = UINavigationController(rootViewController: controller)
//        navController.isNavigationBarHidden = false
//        navController.navigationBar.shadowImage = UIImage()
//        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navController.navigationBar.isTranslucent = true
//        navController.navigationBar.barTintColor = UIColor.randevoo.mainLight
//        navController.navigationBar.isOpaque = false
//        navController.modalPresentationStyle = .fullScreen
        
        gEditProfileNavController = UINavigationController(rootViewController: controller)
        gEditProfileNavController.isNavigationBarHidden = false
        gEditProfileNavController.navigationBar.shadowImage = UIImage()
        gEditProfileNavController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        gEditProfileNavController.navigationBar.isTranslucent = true
        gEditProfileNavController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        gEditProfileNavController.navigationBar.isOpaque = false
        gEditProfileNavController.modalPresentationStyle = .fullScreen
        
        self.present(gEditProfileNavController, animated: true, completion: nil)
    }
    
    @IBAction func handleSite(_ sender: Any?) {
        guard let url = URL(string: "https://\(String(mainSiteUrl))") else { return }
        UIApplication.shared.open(url)
    }

    @IBAction func handleReservation(_ sender: Any?) {
        let controller = BizReservationController()
        
        gBizReservationNavController = UINavigationController(rootViewController: controller)
        gBizReservationNavController.modalPresentationStyle = .fullScreen
        gBizReservationNavController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        gBizReservationNavController.navigationBar.shadowImage = UIImage()
        gBizReservationNavController.navigationBar.isTranslucent = false
        gBizReservationNavController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        gBizReservationNavController.view.backgroundColor = UIColor.randevoo.mainLight
        
        mainTabBarController.present(gBizReservationNavController, animated: true, completion: nil)
//        tabBarController?.present(gBizReservationNavController, animated: true, completion: nil)
    }
    
    @IBAction func handlePhone(_ sender: Any?) {
        guard let info = gBizInfo else { return }
        if info.phoneNumber != "" {
            guard let number = URL(string: "tel://\(String(info.phoneNumber))" ) else { return }
            UIApplication.shared.open(number)
        }
    }
    
    @IBAction func handleEmail(_ sender: Any?) {
        guard let info = gBizInfo else { return }
        if info.email != "" {
            guard let email = URL(string: "mailto:\(String(info.email))" ) else { return }
            UIApplication.shared.open(email)
        }
    }
    
    @IBAction func handleGoogleMaps(_ sender: Any?) {
        guard let business = businessAccount else { return }
        mainTabBar.isHidden = true
        let controller = StoreMapController()
        controller.storeAccount = business.getStoreAccount()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleMenu(_ sender: Any?) {
        let controller = BizMenuController()
        controller.mainTabBarController = self.tabBarController
        controller.businessController = self
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = false
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navController.modalPresentationStyle = .fullScreen
        customPresentViewController(presenter, viewController: navController, animated: true, completion: nil)
    }
    
    @IBAction func handleSwitchAccount(_ sender: Any?) {
        let controller = SwitchAccountController()
        controller.isSetting = false
        controller.mainTabBarController = self.tabBarController
        let navController = UINavigationController(rootViewController: controller)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.barTintColor = UIColor.clear
        navController.navigationBar.isHidden = false
        customPresentViewController(presenter, viewController: navController, animated: true, completion: nil)
    }
    
    private func reloadUsername() {
        if isPersonalAccount {
            guard let personal = personalAccount else { return }
            switchButton.setTitle(personal.username, for: .normal)
        } else {
            guard let business = businessAccount else { return }
            switchButton.setTitle(business.username, for: .normal)
        }
    }

    private func setupNavItems() {
        switchButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        switchButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        switchButton.contentHorizontalAlignment = .right
        switchButton.contentVerticalAlignment = .center
        switchButton.contentMode = .scaleAspectFill
        switchButton.backgroundColor = UIColor.clear
        switchButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        switchButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        switchButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        switchButton.setImage(UIImage(named: "ArrowDown")!.withRenderingMode(.alwaysOriginal), for: .normal)
        switchButton.titleLabel?.font =  UIFont(name: "Quicksand-Bold", size: 23)
        switchButton.setTitleColor(UIColor.randevoo.mainBlack, for: .normal)
        switchButton.titleLabel?.textAlignment = .left
        switchButton.titleLabel?.lineBreakMode = .byTruncatingTail
        switchButton.addTarget(self, action: #selector(handleSwitchAccount(_:)), for: .touchUpInside)
        
        if isPersonalAccount {
            guard let personal = personalAccount else { return }
            switchButton.setTitle(personal.username, for: .normal)
        } else {
            guard let business = businessAccount else { return }
            switchButton.setTitle(business.username, for: .normal)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: switchButton)
        switchButton.snp.makeConstraints{ (make) in
            make.height.equalTo(40)
            make.width.equalTo(self.view.frame.width / 2)
        }

        let reservationBarButton = UIBarButtonItem(image: UIImage(named: "ReservationIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleReservation(_:)))
        let menuBarButton = UIBarButtonItem(image: UIImage(named: "MenuIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMenu(_:)))
        navigationItem.rightBarButtonItems = [menuBarButton, reservationBarButton]
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
            mainTabBar.isHidden = true
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            mainTabBar.isHidden = false
        }
    }
    
    private func presentBizReservation(reservation: Reservation) {
        let controller = ReservedProductController()
        controller.isFromBizReservation = false
        controller.reservation = reservation
        gBizReservedNavController = UINavigationController(rootViewController: controller)
        gBizReservedNavController.modalPresentationStyle = .fullScreen
        gBizReservedNavController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        gBizReservedNavController.navigationBar.shadowImage = UIImage()
        gBizReservedNavController.navigationBar.isTranslucent = true
        gBizReservedNavController.navigationBar.barTintColor = UIColor.clear
        gBizReservedNavController.navigationBar.backgroundColor = UIColor.clear
        gBizReservedNavController.view.backgroundColor = UIColor.randevoo.mainLight
        self.present(gBizReservedNavController, animated: true, completion: nil)
    }
    
    func validateQrCode(qrCode: String) {
        fetchReservation(qrCode: qrCode).then { (check) in
            if check {
                guard let reservation = self.reservation else { return }
                self.presentBizReservation(reservation: reservation.copy())
                self.reservation = nil
            } else {
                self.alert.showAlert(title: "Notice", alert: "This QrCode is invalid", controller: self)
            }
        }
    }
    
    private func fetchReservation(qrCode: String) -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let business = businessAccount else {
                resolve(false)
                return
            }
            self.reservationRef
                .whereField("businessId", isEqualTo: business.id as Any)
                .whereField("qrCode", isEqualTo: qrCode)
                .limit(to: 1)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting category documents: \(err)")
                        resolve(false)
                    } else {
                        if querySnapshot!.documents.count == 0 {
                            resolve(false)
                        }
                        for document in querySnapshot!.documents {
                            let result = Mapper<Reservation>().map(JSONObject: document.data())!
                            self.reservation = result
                            resolve(true)
                        }
                    }
                }
        }
        
    }
}

extension BusinessController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: businessProfileCell, for: indexPath) as! BusinessProfileCell
            header.business = businessAccount
            header.delegate = self
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: bizAboutFlexCell, for: indexPath) as! BizAboutFlexCell
            footer.info = gBizInfo
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
        guard let business = businessAccount else { return CGSize(width: width, height: width) }
        let font = UIFont(name: "Quicksand-Medium", size: 17)!
        let bioWidth = view.frame.width - 40
        var heightOfText = 0.0 as Float
        if business.bio != "" {
            heightOfText = Float(business.bio.heightWithConstrainedWidth(width: bioWidth, font: font))
        }
        var currentHeight: Float = 265
        if business.website != "" {
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
        if isListingCell {
            dispatchLoadController(productId: products[indexPath.item].id)
        }
    }
    
    private func dispatchLoadController(productId: String) {
        gProductInfoController.productId = productId
        gProductInfoController.isFromSave = false
        gProductInfoController.loadUpdate()
        self.navigationController?.present(gProductNavController, animated: true, completion: nil)
    }
}
