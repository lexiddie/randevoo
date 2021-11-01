//
//  MainTabBarController.swift
//  randevoo
//
//  Created by Lex on 8/11/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import SnapKit
import ObjectMapper
import SwiftyJSON
import Cache
import SnapKit
import Hydra
import AlamofireImage
import ImageSlideshow

var isSignIn: Bool = false
var isPersonalAccount: Bool = true
var currentAccountId: String = ""
var personalAccount: PersonalAccount?
var businessAccount: BusinessAccount?
var gBizPeriod: BizPeriod?
var gBizInfo: BizInfo?
var gCategories: [Category] = []
var gSubcategories: [Subcategory] = []
var gVariations: [Variation] = []
var currentMemberId: String = ""

var userListener: ListenerRegistration!
var businessListener: ListenerRegistration!
var messageListener: ListenerRegistration!
var activityListener: ListenerRegistration!

var gImageDownloader: ImageDownloader!

var gProductInfoController: ProductDetailController!
var gProductNavController: UINavigationController!

var gSearchInfoController: SearchInfoController!
var gSearchNavController: UINavigationController!

var gBizReservationController: BizReservationController!
var gBizReservationNavController: UINavigationController!

var gBizMenuNavController: UINavigationController!

var gBizReservedNavController: UINavigationController!

var gEditProfileNavController: UINavigationController!

var gMainNavController: UINavigationController!

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let homeUnselected = UIImage(named: "HomeUnselected")!.withRenderingMode(.alwaysOriginal)
    private let homeSelected = UIImage(named: "HomeSelected")!.withRenderingMode(.alwaysOriginal)
    private let searchUnselected = UIImage(named: "SearchUnselected")!.withRenderingMode(.alwaysOriginal)
    private let searchSelected = UIImage(named: "SearchSelected")!.withRenderingMode(.alwaysOriginal)
    private let reservationUnselected = UIImage(named: "RandevooUnselected")!.withRenderingMode(.alwaysOriginal)
    private let reservationSelected = UIImage(named: "RandevooSelected")!.withRenderingMode(.alwaysOriginal)
    private let listingUnselected = UIImage(named: "ListUnselected")!.withRenderingMode(.alwaysOriginal)
    private let listingSelected = UIImage(named: "ListSelected")!.withRenderingMode(.alwaysOriginal)
    private let inboxUnselected = UIImage(named: "InboxUnselected")!.withRenderingMode(.alwaysOriginal)
    private let inboxSelected = UIImage(named: "InboxSelected")!.withRenderingMode(.alwaysOriginal)
    private let profileUnselected = UIImage(named: "ProfileUnselected")!.withRenderingMode(.alwaysOriginal)
    private let profileSelected = UIImage(named: "ProfileSelected")!.withRenderingMode(.alwaysOriginal)
    
    private let defaults = UserDefaults.standard
    private var switchProvider = SwitchProvider()
    private var categoriesProvider = CategoriesProvider()
    private let alertHelper = AlertHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        tabBar.layer.borderWidth = 0
        tabBar.layer.masksToBounds = true
        tabBar.isTranslucent = true
        tabBar.backgroundColor = UIColor.clear
        tabBar.superview?.backgroundColor = UIColor.clear
        tabBar.layer.backgroundColor = UIColor.clear.cgColor
        tabBar.layer.borderColor = UIColor.clear.cgColor
        tabBar.barTintColor = UIColor.clear
        tabBar.backgroundImage = UIImage.init(color: UIColor.clear)
        tabBar.shadowImage = UIImage.init(color: UIColor.clear)
        fetchAccountInfo()
        setupRoundTabbar()
        setupTabBar()
        categoriesProvider.initiateCategory()
        
        gImageDownloader = ImageDownloader()
        
        loadGlobalControllers()
    }
    
    private func fetchAccountInfo() {
        switchProvider.fetchAccountState()
        switchProvider.fetchCurrentAccount()
    }
    
    func loadGlobalControllers() {
        gProductInfoController = ProductDetailController()
        
        gProductNavController = UINavigationController(rootViewController: gProductInfoController)
        gProductNavController.modalPresentationStyle = .fullScreen
        gProductNavController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        gProductNavController.navigationBar.shadowImage = UIImage()
        gProductNavController.navigationBar.isTranslucent = true
        gProductNavController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        gProductNavController.view.backgroundColor = UIColor.randevoo.mainLight
        
        gSearchInfoController = SearchInfoController()
        
        gSearchNavController = UINavigationController(rootViewController: gSearchInfoController)
        gSearchNavController.modalTransitionStyle = .crossDissolve
        gSearchNavController.modalPresentationStyle = .fullScreen
        gSearchNavController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        gSearchNavController.navigationBar.shadowImage = UIImage()
        gSearchNavController.navigationBar.isTranslucent = false
        gSearchNavController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        
//        gBizReservationController = BizReservationController()
//
//        gBizReservationNavController = UINavigationController(rootViewController: gBizReservationController)
//        gBizReservationNavController.modalPresentationStyle = .fullScreen
//        gBizReservationNavController.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        gBizReservationNavController.navigationBar.shadowImage = UIImage()
//        gBizReservationNavController.navigationBar.isTranslucent = false
//        gBizReservationNavController.navigationBar.barTintColor = UIColor.randevoo.mainLight
//        gBizReservationNavController.view.backgroundColor = UIColor.randevoo.mainLight
    }

    
    func fetchAccounts() {
        if let personalCache: PersonalAccount = FCache.get("personal"), !FCache.isExpired("personal") {
            personalAccount = personalCache
            let personalJson = Mapper().toJSONString(personalCache, prettyPrint: true)!
            print("\nRetrieved Cache Personal at MainTabBar: \(personalJson)")
            if let businessCache: BusinessAccount = FCache.get("business"), !FCache.isExpired("business") {
                businessAccount = businessCache
                let businessJson = Mapper().toJSONString(businessCache, prettyPrint: true)!
                print("\nRetrieved Cache Business at MainTabBar: \(businessJson)")
            }
        }
    }
    
    func showBanAlert() {
        alertHelper.showAlert(title: "Notice😈", alert: "Your store account has been banned!🧐\nPlease contact our support info@randevoo.app", controller: self)
    }
    
    private func setupRoundTabbar(){
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 25, y: 0, width: self.tabBar.bounds.width - 50, height: self.tabBar.bounds.height), cornerRadius: (self.tabBar.frame.width / 2)).cgPath
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3.0)
        layer.shadowOpacity = 0.3
        layer.borderWidth = 0
        layer.opacity = 1.0
        layer.isHidden = false
        layer.masksToBounds = false
        layer.fillColor = UIColor.white.cgColor
        self.tabBar.layer.insertSublayer(layer, at: 0)
        if let items = self.tabBar.items {
          items.forEach { item in item.imageInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0) }
        }
        self.tabBar.itemWidth = 35
        self.tabBar.itemPositioning = .centered
    }
    
    func setupTabBar() {
        let homeNavigation = templateNavController(unselectImage: homeUnselected, selectedImage: homeSelected, rootViewController: HomeController())
        let searchNavigation = templateNavController(unselectImage: searchUnselected, selectedImage: searchSelected, rootViewController: SearchController())
        let reservationNavigation = templateNavController(unselectImage: reservationUnselected, selectedImage: reservationSelected, rootViewController: ReservationController())
        let listingNavigation = templateNavController(unselectImage: listingUnselected, selectedImage: listingSelected, rootViewController: ListingController())
//        let inboxNavigation = templateNavController(unselectImage: inboxUnselected, selectedImage: inboxSelected, rootViewController: NotificationsController())
        let inboxNavigation = templateNavController(unselectImage: inboxUnselected, selectedImage: inboxSelected, rootViewController: InboxController())
        let personalNavigation = templateNavController(unselectImage: profileUnselected, selectedImage: profileSelected, rootViewController: PersonalController())
        let businessNavigation = templateNavController(unselectImage: profileUnselected, selectedImage: profileSelected, rootViewController: BusinessController())
        
        if isPersonalAccount {
            viewControllers = [homeNavigation, searchNavigation, reservationNavigation, inboxNavigation, personalNavigation]
        } else {
//            viewControllers = [homeNavigation, searchNavigation, listingNavigation, notificationsNavigation, businessNavigation]
            viewControllers = [homeNavigation, searchNavigation, listingNavigation, inboxNavigation, businessNavigation]
        }
        
        guard let items = tabBar.items else { return }
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5 , right: 0)
        }
    }
     
    private func templateNavController(unselectImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewNavigation = UINavigationController(rootViewController: rootViewController)
        viewNavigation.tabBarItem.image = unselectImage.withRenderingMode(.alwaysOriginal)
        viewNavigation.tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
        viewNavigation.navigationBar.setBackgroundImage(UIImage(), for: .default)
        viewNavigation.navigationBar.shadowImage = UIImage()
        viewNavigation.navigationBar.isTranslucent = false
        viewNavigation.navigationBar.barTintColor = UIColor.randevoo.mainLight
        viewNavigation.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        viewNavigation.view.backgroundColor = UIColor.randevoo.mainLight
        return viewNavigation
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 && !isPersonalAccount {
            let controller = ListingController()
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .fullScreen
            navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navController.navigationBar.shadowImage = UIImage()
            navController.navigationBar.isTranslucent = false
            navController.navigationBar.barTintColor = UIColor.randevoo.mainLight
            present(navController, animated: true, completion: nil)
            return false
        }
        return true
    }
}
