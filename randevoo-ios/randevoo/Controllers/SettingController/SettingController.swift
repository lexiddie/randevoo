//
//  SettingController.swift
//  randevoo
//
//  Created by Lex on 23/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseMessaging
import ObjectMapper
import SwiftyJSON
import Presentr
import Hydra

class Setting: NSObject {
    let parent: ParentSetting
    let child: ChildSetting
    let controller: UIViewController?

    init(parent: ParentSetting, child: ChildSetting, controller: UIViewController?) {
        self.parent = parent
        self.child = child
        self.controller = controller
    }
}

class SnapSize: NSObject {
    let totalList: Int
    let currentIndex: Int

    init(totalList: Int, currentIndex: Int) {
        self.totalList = totalList
        self.currentIndex = currentIndex
    }
}

class SettingController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
    private let alert = AlertHelper()
    private let firebaseAuth = Auth.auth()
    private let devicesProvider = DevicesProvider()
    
    var mainTabBarController: UITabBarController!
    
    let settingTableCell = "settingTableCell"
    var settingTableView: UITableView!
    
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
    
//    let presenter: Presentr = {
//        let presentr = Presentr(presentationType: .bottomHalf)
//        presentr.roundCorners = true
//        presentr.cornerRadius = 15
//        presentr.backgroundColor = UIColor.black
//        presentr.backgroundOpacity = 0.7
//        presentr.transitionType = .coverVertical
//        presentr.dismissTransitionType = .coverVertical
//        presentr.dismissOnSwipe = true
//        presentr.dismissAnimated = true
//        presentr.dismissOnSwipeDirection = .default
//        return presentr
//    }()
    
//    var settings: [[Setting]] = [[Setting(parent: .account, child: .accountSettings, controller: AccountSettingsController()),
//                                  Setting(parent: .account, child: .getFreeBusinessAccount, controller: IntroBizController()),
//                                  Setting(parent: .account, child: .notification, controller: NotificationSettingController()),
//                                  Setting(parent: .account, child: .privacyData, controller: PrivacyDataController())],[
//                                    Setting(parent: .helpSupport, child: .reportProblem, controller: ReportProblemController()),
//                                    Setting(parent: .helpSupport, child: .helpCenter, controller: HelpCenterController()),
//                                    Setting(parent: .helpSupport, child: .privacySecurityHelp, controller: PrivacySecurityHelpController()),
//                                    Setting(parent: .helpSupport, child: .contactUs, controller: ContactUsController())],[
//                                        Setting(parent: .about, child: .version, controller: nil),
//                                        Setting(parent: .about, child: .aboutRandevoo, controller: AboutController()),
//                                        Setting(parent: .about, child: .termsService, controller: TermsServiceController()),
//                                        Setting(parent: .about, child: .privacyPolicy, controller: PrivacyPolicyController()),
//                                        Setting(parent: .about, child: .openSourceLibraries, controller: OpenSourceLibrariesController())],[
//                                            Setting(parent: .action, child: .switchAccount, controller: nil),
//                                            Setting(parent: .action, child: .signOut, controller: nil)]]
    
    
    var settings: [[Setting]] = [[Setting(parent: .account, child: .getFreeBusinessAccount, controller: IntroBizController()),
                                  Setting(parent: .account, child: .notification, controller: NotificationSettingController())],[
                                    Setting(parent: .helpSupport, child: .contactUs, controller: ContactUsController())],[
                                        Setting(parent: .about, child: .version, controller: nil)],[
                                            Setting(parent: .action, child: .switchAccount, controller: nil),
                                            Setting(parent: .action, child: .signOut, controller: nil)]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialTableView()
        filterAccountType()
        // use to clean personalProfileImage
//        try? storage!.removeObject(forKey: "personalProfileImage")
    }
    
    private func initialView() {
        let view = SettingView(frame: self.view.frame)
        self.settingTableView = view.settingTableView
        self.view = view
    }
    
    private func initialTableView() {
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.register(SettingTableCell.self, forCellReuseIdentifier: settingTableCell)
        
//        self.settingTableView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//        settingTableView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//        settingTableView.alwaysBounceHorizontal = true
//        settingTableView.clipsToBounds = false
//        settingTableView.showsHorizontalScrollIndicator = false
    }
    
    private func filterAccountType() {
        let personalIgnores: [ChildSetting] = []
        let businessIgnores: [ChildSetting] = [.getFreeBusinessAccount]
        
//        let businessIgnores: [ChildSetting] = [.getFreeBusinessAccount, .accountSettings, .privacyData, .reportProblem, .helpCenter, .privacySecurityHelp, .aboutRandevoo, .termsService, .privacyPolicy, .openSourceLibraries]
        
        for (first, setting) in settings.enumerated() {
            for (second, element) in setting.enumerated() {
                if isPersonalAccount {
                    if personalIgnores.contains(where: {$0.rawValue == element.child.rawValue}) {
                        settings[first].remove(at: second)
                    }
                } else {
                    if businessIgnores.contains(where: {$0.rawValue == element.child.rawValue}) {
                        settings[first].remove(at: second)
                    }
                }
            }
        }
        settingTableView.reloadData()
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Settings"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel

        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(named: "DismissIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        dismissButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentHorizontalAlignment = .center
        dismissButton.contentVerticalAlignment = .center
        dismissButton.contentMode = .scaleAspectFit
        dismissButton.backgroundColor = UIColor.clear
        dismissButton.layer.cornerRadius = 8
        dismissButton.addTarget(self, action: #selector(handleDismiss(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        dismissButton.snp.makeConstraints{ (make) in
           make.height.width.equalTo(40)
        }

//        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    }
    
    private func handleSignOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let title = NSAttributedString(string: "Would you like to sign out?", attributes: [NSAttributedString.Key.font: UIFont(name: "Quicksand-Bold", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black])
        alertController.setValue(title, forKey: "attributedMessage")
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            let initiateSignIn = ["isSignIn": false]
            self.defaults.set(initiateSignIn, forKey: "signIn")
            let mainController = MainController()
            mainController.mainTabBarController = self.mainTabBarController
            
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
            
            let tabBarController = self.mainTabBarController as! MainTabBarController
            tabBarController.setupTabBar()

            self.mainTabBarController.selectedIndex = 0
            self.dismiss(animated: true) {
                self.mainTabBarController.present(gMainNavController, animated: true, completion: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func removeToken() {
        guard let user = personalAccount else { return }
        guard let fcmToken = Messaging.messaging().fcmToken else { return }
        self.devicesProvider.removeToken(userId: user.id, fcmToken: fcmToken)
    }
}


extension SettingController {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingTableCell, for: indexPath) as! SettingTableCell
        cell.setting = settings[indexPath.section][indexPath.row]
        cell.snapSize = SnapSize(totalList: settings[indexPath.section].count, currentIndex: indexPath.row)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = settings[indexPath.section][indexPath.row].controller else {
            let mainSetting = settings[indexPath.section][indexPath.row]
            if mainSetting.child == .signOut {
                handleSignOut()
            } else if mainSetting.child == .switchAccount {
                let controller = SwitchAccountController()
                controller.isSetting = true
                controller.mainTabBarController = self.mainTabBarController
                controller.previousController = self
                let navController = UINavigationController(rootViewController: controller)
                navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
                navController.navigationBar.shadowImage = UIImage()
                navController.navigationBar.isTranslucent = true
                navController.navigationBar.barTintColor = UIColor.clear
                navController.navigationBar.isHidden = false
                customPresentViewController(presenter, viewController: navController, animated: true, completion: nil)
            }
            print("This controller is nil")
            return
        }
        let currentSetting = settings[indexPath.section][indexPath.row]
        if currentSetting.parent == .account && currentSetting.child == .getFreeBusinessAccount {
            let controller = currentSetting.controller as! IntroBizController
            controller.previousController = self
            let navController = UINavigationController(rootViewController: controller as UIViewController)
            navController.modalPresentationStyle = .fullScreen
            navController.navigationBar.shadowImage = UIImage()
            navController.navigationBar.isTranslucent = true
            navController.navigationBar.barTintColor = UIColor.randevoo.mainLight
            self.present(navController, animated: true, completion: nil)
        } else if currentSetting.parent == .account && currentSetting.child == .notification {
            if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        } else if currentSetting.parent == .helpSupport && currentSetting.child == .contactUs {
            let address = "info@randevoo.app"
            guard let email = URL(string: "mailto:\(String(address))" ) else { return }
            UIApplication.shared.open(email)
        }else {
            self.navigationController?.pushViewController(currentSetting.controller! as UIViewController, animated: true)
        }
    }
}
 
