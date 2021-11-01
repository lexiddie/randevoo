//
//  PersonalController.swift
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

class PersonalController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var mainTabBar: UITabBar!
    var mainSiteUrl: String! = ""
    
    let personalCell = "personalCell"
    let reviewCell = "reviewCell"
    let aboutCell = "aboutCell"
    let productGridCell = "productGridCell"
    
    private let alert = AlertHelper()
    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
    private var userRef: CollectionReference!
    private let firebaseAuth = Auth.auth()
    private let devicesProvider = DevicesProvider()
    
    private var refreshControl = UIRefreshControl()
    private var friendlyLabel: UILabel!
    private var personalCollectionView: UICollectionView!
    private var switchButton = UIButton(type: .system)
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialCollectionView()
        initiateFirestore()
        updateRealtimeUser()
        
        mainTabBarController = (self.tabBarController as! MainTabBarController)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshControl.endRefreshing()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.isOpaque = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
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
    }
    
    private func displayInfo() {
        if personalAccount?.website != "" {
            mainSiteUrl = personalAccount?.website
        }
        reloadUsername()
        personalCollectionView.reloadData()
    }
    
    func fetchAccounts() {
        if let personalCache: PersonalAccount = FCache.get("personal"), !FCache.isExpired("personal") {
            personalAccount = personalCache
            let personalJson = Mapper().toJSONString(personalCache, prettyPrint: true)!
            print("\nRetrieved Cache Personal at PersonalController: \(personalJson)")
            displayInfo()
        }
    }
    
    private func updateRealtimeUser() {
        fetchAccounts()
        let mainTabBarController = self.tabBarController as! MainTabBarController
        mainTabBar = mainTabBarController.tabBar
        if !isSignIn {
            print("The running app is not signin!")
            return
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
                
                self.displayInfo()
                FCache.set(personalAccount, key: "personal")
                print("Added Personal Account Into Cache")
                let userJson = Mapper().toJSONString(personalAccount!, prettyPrint: true)!
                print("Personal Account: \(userJson)")
                resolve(true)
            }
        }
    }
    
    private func initialView() {
        let view = PersonalView(frame: self.view.frame)
        self.personalCollectionView = view.personalCollectionView
        self.view = view
    }
    
    private func initialCollectionView() {
        personalCollectionView.delegate = self
        personalCollectionView.dataSource = self
        personalCollectionView.register(PersonalProfileCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: personalCell)
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: UIControl.Event.valueChanged)
        personalCollectionView.addSubview(refreshControl)
    }
    
    @IBAction func refreshList(_ sender: Any?) {
        displayInfo()
        refreshControl.endRefreshing()
    }
    
    @IBAction func handleEditProfile(_ sender: Any?) {
        guard let personal = personalAccount else { return }
        let controller = EditPersonalProfileController()
        controller.personal = personal.copy()
        
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
    
    @IBAction func handleSetting(_ sender: Any?) {
        let controller = SettingController()
        controller.mainTabBarController = self.tabBarController
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = false
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navController.navigationBar.isOpaque = true
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
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
            make.width.equalTo(200)
        }
        
        let settingBarButton = UIBarButtonItem(image: UIImage(named: "GearIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSetting(_:)))
        navigationItem.rightBarButtonItems = [settingBarButton]
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
}


extension PersonalController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: personalCell, for: indexPath) as! PersonalProfileCell
        header.personal = personalAccount
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        guard let personal = personalAccount else { return CGSize(width: width, height: width) }
        let font = UIFont(name: "Quicksand-Medium", size: 17)!
        let bioWidth = view.frame.width - 40
        var heightOfText = 0.0 as Float
        if personal.bio != "" {
            heightOfText = Float(personal.bio.heightWithConstrainedWidth(width: bioWidth, font: font))
        }
        var currentHeight: Float = 265
        if personal.website != "" {
            currentHeight += 25
        }
        if personal.location != "" {
            currentHeight += 25
        }
        return CGSize(width: width, height: CGFloat(currentHeight + heightOfText) + 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
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
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}
