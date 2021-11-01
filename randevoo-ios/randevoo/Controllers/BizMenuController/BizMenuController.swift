//
//  BizMenuController.swift
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

enum MenuItem: String {
    case settings = "Settings"
    case bizInformation = "Business Information"
    case bizReservation = "Reservations"
    case bizHours = "Business Hours"
    case qrCode = "QR Code"
    case yourListings = "Manage Products"
    case yourCollections = "Your Collections"
}

class BizMenu: NSObject {
    let name: MenuItem!
    let iconPath: UIImage!
    let controller: UIViewController?

    init(name: MenuItem, iconPath: String, controller: UIViewController?) {
        self.name = name
        self.iconPath = UIImage(named: iconPath)!.withRenderingMode(.alwaysOriginal)
        self.controller = controller
    }
}

class BizMenuController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var mainTabBarController: UITabBarController!
    var businessController: UIViewController!
    
    private var bizMenus: [BizMenu] = [BizMenu(name: .settings, iconPath: "GearIcon", controller: SettingController()),
                                       BizMenu(name: .bizInformation, iconPath: "BizInfoIcon", controller: BizInfoController()),
                                       BizMenu(name: .bizHours, iconPath: "TimeslotIcon", controller: BusinessHoursController()),
                                       BizMenu(name: .qrCode, iconPath: "QrCode", controller: ScannerController()),
                                       BizMenu(name: .yourListings, iconPath: "ProductTagIcon", controller: BizListingController())]
    
    private let bizMenuCell = "bizMenuCell"
    private var bizMenuCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        initialCollectionView()
    }
    
    private func initialView() {
        let view = BizMenuView(frame: self.view.frame)
        self.bizMenuCollectionView = view.bizMenuCollectionView
        self.view = view
    }
    
    private func initialCollectionView() {
        bizMenuCollectionView.delegate = self
        bizMenuCollectionView.dataSource = self
        bizMenuCollectionView.register(BizMenuCell.self, forCellWithReuseIdentifier: bizMenuCell)
        bizMenuCollectionView.isScrollEnabled = false
    }
}

extension BizMenuController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bizMenus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bizMenuCell, for: indexPath) as! BizMenuCell
        cell.bizMenu = bizMenus[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bizMenu = bizMenus[indexPath.item]
        if bizMenu.name == .settings  {
            let controller = bizMenu.controller as! SettingController
            controller.mainTabBarController = mainTabBarController
            presentNavController(controller: controller)
        } else if bizMenu.name == .bizInformation {
            let controller = bizMenu.controller as! BizInfoController
            presentNavController(controller: controller)
        } else if bizMenu.name == .bizReservation {
            let controller = bizMenu.controller as! BizReservationController
            presentNavController(controller: controller)
        } else if bizMenu.name == .bizHours {
            let controller = bizMenu.controller as! BusinessHoursController
            presentNavController(controller: controller)
        } else if bizMenu.name == .qrCode {
            let controller = bizMenu.controller as! ScannerController
            controller.businessController = businessController
            presentNavController(controller: controller)
        } else if bizMenu.name == .yourListings {
            let controller = bizMenu.controller as! BizListingController
            presentNavController(controller: controller)
        } else if bizMenu.name == .yourCollections {
            let controller = bizMenu.controller as! BizCollectionController
            presentNavController(controller: controller)
        }
        
    }
    
    private func presentNavController(controller: UIViewController) {
        gBizMenuNavController = UINavigationController(rootViewController: controller)
        gBizMenuNavController.modalPresentationStyle = .fullScreen
        gBizMenuNavController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        gBizMenuNavController.navigationBar.shadowImage = UIImage()
        gBizMenuNavController.navigationBar.isTranslucent = false
        gBizMenuNavController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        gBizMenuNavController.view.backgroundColor = UIColor.randevoo.mainLight
        self.navigationController?.dismiss(animated: true, completion: {
            self.mainTabBarController.present(gBizMenuNavController, animated: true, completion: nil)
        })
    }
}
