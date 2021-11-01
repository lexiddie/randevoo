//
//  SwitchAccountController.swift
//  randevoo
//
//  Created by Lex on 9/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import ObjectMapper
import SwiftyJSON
import Presentr
import Hydra

class SwitchAccountController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var isSetting: Bool = false
    var mainTabBarController: UITabBarController!
    var previousController: UIViewController!
    
    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
    private let accountsProvider = AccountsProvider()
    private let deviceProvider = DevicesProvider()
    private let switchProvider = SwitchProvider()
    private let alertHelper = AlertHelper()
    private var accounts: [Account] = []
    
    private let cellHeight: CGFloat = 70
    private let switchAccountFlexCell = "switchAccountFlexCell"
    private var switchAccountCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        initialCollectionView()
        fetchBusinessAccounts()
    }
    
    private func initialView() {
        let view = SwitchAccountView(frame: self.view.frame)
        self.switchAccountCollectionView = view.switchAccountCollectionView
        self.view = view
    }
    
    private func initialCollectionView() {
        switchAccountCollectionView.delegate = self
        switchAccountCollectionView.dataSource = self
        switchAccountCollectionView.register(SwitchAccountFlexCell.self, forCellWithReuseIdentifier: switchAccountFlexCell)
        switchAccountCollectionView.isScrollEnabled = false
    }
    
    private func fetchBusinessAccounts() {
        if let records: [Account] = FCache.get("gAccounts"), !FCache.isExpired("gAccounts") {
            print("Get gAccounts From Cache")
            accounts = records
            switchAccountCollectionView.reloadData()
        }
        
        guard let personal = personalAccount else { return }
        accounts.removeAll()
        accounts.append(Account(id: personal.id, username: personal.username, profileUrl: personal.profileUrl, isPersonal: true))
        accountsProvider.findBusinessAccounts(userId: personal.id).then { (businesses) in
            self.accounts.append(contentsOf: businesses)
            self.switchAccountCollectionView.reloadData()
            FCache.set(self.accounts, key: "gAccounts")
            print("Update gAccounts To Cache")
        }
    }
    
    private func fetchBusinessAccount(businessId: String) -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.db.collection("businesses").document(businessId).getDocument { (document, error) in
                if let document = document, document.exists {
                    let record = Mapper<BusinessAccount>().map(JSONObject: document.data())!
                    businessAccount = record
                    FCache.set(record, key: "business")
                    print("Added Business Account Into Cache In Switch Account")
                    resolve(true)
                } else {
                    print("Document does not exist")
                    resolve(false)
                }
            }
        }
    }
}

extension SwitchAccountController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: cellHeight)
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
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: switchAccountFlexCell, for: indexPath) as! SwitchAccountFlexCell
        cell.account = accounts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let current = accounts[indexPath.item]
        if  current.id == currentAccountId {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else if current.isPersonal {
            guard let user = personalAccount else { return }
            deviceProvider.validateDeviceToken(accountId: user.id)
            switchProvider.startSwitchAccount(mainTabBarController: mainTabBarController, accountId: user.id, isPersonal: true)
            self.navigationController?.dismiss(animated: true, completion: {
                if self.isSetting {
                    let settingController = self.previousController as! SettingController
                    settingController.dismiss(animated: true)
                }
            })
        } else {
            fetchBusinessAccount(businessId: current.id).then { (check) in
                if check {
                    guard let business = businessAccount else { return }
                    if business.isBanned {
                        self.alertHelper.showAlert(title: "Notice😈", alert: "Your account has been banned!🧐\nPlease contact our support info@randevoo.app", controller: self)
                    } else {
                        self.deviceProvider.validateDeviceToken(accountId: business.id)
                        self.switchProvider.startSwitchAccount(mainTabBarController: self.mainTabBarController, accountId: business.id, isPersonal: false)
                        self.navigationController?.dismiss(animated: true, completion: {
                            if self.isSetting {
                                let settingController = self.previousController as! SettingController
                                settingController.dismiss(animated: true)
                            }
                        })
                    }
                }
            }
        }
    }
}
