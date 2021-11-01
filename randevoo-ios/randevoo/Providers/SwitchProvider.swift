//
//  SwitchProvider.swift
//  randevoo
//
//  Created by Lex on 4/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Hydra
import ObjectMapper
import SwiftyJSON


class SwitchProvider {
    
    func fetchAccountState() {
        if let state: Bool = FCache.get("accountState"), !FCache.isExpired("accountState") {
            isPersonalAccount = state
            // print("Account State from cache:", state)
        } else {
            isPersonalAccount = false
        }
    }
    
    func fetchCurrentAccount() {
        if let current: String = FCache.get("currentAccount"), !FCache.isExpired("currentAccount") {
            currentAccountId = current
            // print("Current Account from cache:", current)
        }
    }
    
    func setupCurrentAccount(accountId: String) {
        currentAccountId = accountId
        FCache.set(accountId, key: "currentAccount")
        print("Current Account is added into cache:", accountId)
    }
    
    func setupAccountState(isPersonal: Bool) {
        isPersonalAccount = isPersonal
        FCache.set(isPersonal, key: "accountState")
        print("Account State is added into cache:", isPersonal)
        if isPersonal {
            guard let businessListener = businessListener else { return }
            businessListener.remove()
        } else {
            guard let userListener = userListener else { return }
            userListener.remove()
        }
        cleanMessage()
        cleanActivity()
        cleanPersonal()
    }
    
    private func cleanPersonal() {
        guard let userListener = userListener else { return }
        userListener.remove()
    }
    
    func startSwitchAccount(mainTabBarController: UITabBarController, accountId: String, isPersonal: Bool, selectFirst: Bool = false) {
        setupCurrentAccount(accountId: accountId)
        setupAccountState(isPersonal: isPersonal)
        let tabBarController = mainTabBarController as! MainTabBarController
        tabBarController.fetchAccounts()
        tabBarController.setupTabBar()
        tabBarController.loadGlobalControllers()
        if selectFirst {
            tabBarController.selectedIndex = 0
        }
    }
    
//    private func fetchBusinessAccount(businessId: String) -> Promise<Bool> {
//        let bizRef = db.collection("businesses")
//           return Promise<Bool>(in: .background) { (resolve, reject, _) in
//            bizRef.document(businessId).getDocument { (document, error) in
//                   if let document = document, document.exists {
//                       let record = Mapper<BusinessAccount>().map(JSONObject: document.data())!
//                       businessAccount = record
//                       FCache.set(record, key: "business")
//                       print("Added Business Account Into Cache In Switch Provider")
//                       resolve(true)
//                   } else {
//                       print("Document does not exist")
//                       resolve(false)
//                   }
//               }
//           }
//       }
    
    private func cleanMessage() {
        guard let messageListener = messageListener else { return }
        messageListener.remove()
    }
    
    private func cleanActivity() {
        guard let activityListener = activityListener else { return }
        activityListener.remove()
    }
}
