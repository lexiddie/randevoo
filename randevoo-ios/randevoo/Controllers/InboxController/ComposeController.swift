//
//  ComposeController.swift
//  randevoo
//
//  Created by Lex on 10/3/21.
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
import InstantSearchClient

class ComposeController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchBarDelegate {

    var previousController: UIViewController!
    
    private let db = Firestore.firestore()
    private var businessRef: CollectionReference!
    private var userRef: CollectionReference!
    private var messagesProvider = MessagesProvider()
    private var messenger: Messenger!
    private let client = Client(appID: "0WM56Q50VW", apiKey: "510282f8fdcbff1957076a5159bc0ed9")
    private var businessIndex: InstantSearchClient.Index!
    private var userIndex: InstantSearchClient.Index!
    let query = Query()
    var searchId = 0
    var displayedSearchId = -1
    var loadedPage: UInt = 0
    var numberPages: UInt = 0
    
    private var searchKey: String = ""
    private var stores: [Store] = []
    
    var storeFlexCell = "storeFlexCell"
    
    private var composeCollectionView: UICollectionView!
    private var friendlyLabel: UILabel!
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        var searchText = isPersonalAccount ? "Search Stores" : "Search Users"
        searchBar.placeholder = "\(String(searchText))"
        searchBar.isUserInteractionEnabled = true
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        setupNavItems()
        initialCollectionView()
        initiateFirestore()
        initiateSearchAlgolia()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    private func initialView() {
        let view = ComposeView(frame: self.view.frame)
        self.composeCollectionView = view.composeCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.view = view
        self.hideKeyboardWhenTappedAround()
    }

    private func initialCollectionView(){
        composeCollectionView.delegate = self
        composeCollectionView.dataSource = self
        composeCollectionView.register(StoreFlexCell.self, forCellWithReuseIdentifier: storeFlexCell)
        composeCollectionView.keyboardDismissMode = .onDrag
        loadFriendlyLabel()
    }
    
    private func loadFriendlyLabel() {
        if stores.count == 0 {
            friendlyLabel.text = "No stores to show😴"
        }  else {
            friendlyLabel.text = nil
        }
    }
    
    private func initiateFirestore() {
        businessRef = db.collection("businesses")
        userRef = db.collection("users")
    }
    
    private func initiateSearchAlgolia() {
        businessIndex = client.index(withName: "prod_businesses")
        userIndex = client.index(withName: "prod_users")
        query.hitsPerPage = 15
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchKey = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        query.query = searchKey
        if searchText.isEmpty || searchText == "" {
            cleanSearch()
            print("It's empty, type")
        }
        else {
            fetchSelection()
        }
    }
    
    private func cleanSearch() {
        stores = []
        composeCollectionView.reloadData()
        loadFriendlyLabel()
    }
    
    private func fetchSelection() {
        if searchKey.isEmpty || searchKey == "" {
            print("Search Key is empty cannot be query!")
            cleanSearch()
            return
        } else {
            businessIndex.search(query, completionHandler: { (content, error) in
                if let data = content!["hits"] {
                    let currents = Mapper<BusinessDto>().mapArray(JSONObject: data)!
                    self.searchBusinesses(currents: currents)
                }
            })
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
    
    private func searchBusinesses(currents: [BusinessDto]) {
        if !searchKey.isEmpty || searchKey != "" {
            var tempList: [Store] = []
            for i in currents {
                let current = Store(id: i.id, name: i.name, username: i.username, location: i.location, type: i.type, profileUrl: i.profileUrl)
                tempList.append(current)
            }
            stores = tempList
            composeCollectionView.reloadData()
            loadFriendlyLabel()
        }
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }

    private func setupNavItems() {
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDismiss(_:)))
        doneBarButton.tintColor = UIColor.randevoo.mainBlack
        navigationItem.rightBarButtonItem = doneBarButton
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        UIView.animate(withDuration: 0.7, animations: {
            self.searchBar.snp.makeConstraints{ (make) in
                make.height.equalTo(40)
                make.width.equalTo(self.view.frame.width - 90)
            }
        }, completion: nil)

        searchBar.delegate = self

        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension ComposeController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stores.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: storeFlexCell, for: indexPath) as! StoreFlexCell
        cell.store = stores[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let store = stores[indexPath.item]
        let accountId = getAccountId()

        self.messagesProvider.checkMessenger(accountId: accountId, memberId: store.id).then { (check) in
            if check {
                self.messenger = self.messagesProvider.messenger
                let json = Mapper().toJSONString(self.messenger, prettyPrint: true)!
                print("Member is existed, : \(json)")
                self.presentMessageController(messenger: self.messenger)
            } else {
                self.messagesProvider.createMessenger(accountId: accountId, memberId: store.id).then { (messenger) in
                    self.messenger = messenger
                    let json = Mapper().toJSONString(messenger, prettyPrint: true)!
                    print("Messenger is created, : \(json)")
                    self.presentMessageController(messenger: messenger)
                }
            }
        }
    }
    
    private func presentMessageController(messenger: Messenger) {
        self.navigationController?.dismiss(animated: true, completion: {
            let previous = self.previousController as! InboxController
            let controller = MessageController()
            controller.messenger = messenger
            previous.mainTabBar.isHidden = true
            previous.navigationController?.pushViewController(controller, animated: true)
        })
    }
}
