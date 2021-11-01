//
//  InboxController.swift
//  randevoo
//
//  Created by Lex on 23/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
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

class InboxPage: NSObject {
    let label: String
    var isSelected: Bool

    init(label: String, isSelected: Bool) {
        self.label = label
        self.isSelected = isSelected
    }
}

class InboxController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, InboxPageViewDelegate {

    var mainTabBar: UITabBar!
    
    private var alertHelper = AlertHelper()
    private let db = Firestore.firestore()
    private var businessRef: CollectionReference!
    private var userRef: CollectionReference!
    private var chatRef: CollectionReference!
    private var reservationRef: CollectionReference!
    private var notificationRef: CollectionReference!
    private let timestampHelper = TimestampHelper()
    private let messagesProvider = MessagesProvider()
    private var alertController: UIAlertController!
    
    private var inboxPages: [InboxPage] = [InboxPage(label: "Messages", isSelected: true),
                                           InboxPage(label: "Activities", isSelected: false)]
    
    private let messengerCell = "messengerCell"
    private let activityCell = "activityCell"
    
    private var cachedAccounts: [User] = []
    private var cachedSenders: [User] = []
    private var messengers: [Messenger] = []
    private var activities: [Activity] = []
    private var selectInbox = 0
    private var inboxCollectionView: UICollectionView!
    private var friendlyLabel: UILabel!
    
    private lazy var inboxPageView: InboxPageView = {
        let view = InboxPageView()
        view.inboxPages = self.inboxPages
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialCollectionView()
        initiateFirestore()
        fetchSelection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let mainTabBarController = self.tabBarController as! MainTabBarController
        mainTabBar = mainTabBarController.tabBar
        mainTabBar.isHidden = false
        
        inboxPageView.animateBar(index: selectInbox, duration: 0.4)
        
        fetchSelection()
        
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func initialView() {
        let view = InboxView(frame: self.view.frame)
        self.inboxCollectionView = view.inboxCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.view = view
        self.view.addSubview(inboxPageView)
        inboxPageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(40)
            make.centerX.equalTo(self.view)
            make.left.right.lessThanOrEqualTo(self.view)
        }
        self.hideKeyboardWhenTappedAround()
    }
    
    private func initialCollectionView() {
        inboxCollectionView.delegate = self
        inboxCollectionView.dataSource = self
        inboxCollectionView.register(MessengerCell.self, forCellWithReuseIdentifier: messengerCell)
        inboxCollectionView.register(ActivityCell.self, forCellWithReuseIdentifier: activityCell)
        inboxCollectionView.isScrollEnabled = true
        inboxCollectionView.keyboardDismissMode = .onDrag
    }
    
    private func initiateFirestore() {
        businessRef = db.collection("businesses")
        userRef = db.collection("users")
        chatRef = db.collection("chats")
        notificationRef = db.collection("notifications")
        reservationRef = db.collection("reservations")
    }
    
    private func loadFriendlyLabel() {
        if selectInbox == 0 && messengers.count == 0 {
            friendlyLabel.text = "No messages to show😴"
        } else if selectInbox == 1 && activities.count == 0 {
            friendlyLabel.text = "No activities to show😴"
        } else {
            friendlyLabel.text = nil
        }
    }
    
    private func fetchSelection() {
        inboxCollectionView.reloadData()
        loadFriendlyLabel()
        if selectInbox == 0 {
            fetchMessages()
            if isPersonalAccount {
                enableComposeBar(state: true)
            }
        } else if selectInbox == 1 {
            fetchActivities()
            enableComposeBar(state: false)
        }
    }
    
    @IBAction func handleCompose(_ sender: Any?) {
        let controller = ComposeController()
        controller.previousController = self
        let navController = UINavigationController(rootViewController: controller)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        self.present(navController, animated: true, completion: nil)
    }
    
    private func enableComposeBar(state: Bool) {
        if state {
            let composeBarButton = UIBarButtonItem(image: UIImage(named: "ComposeIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCompose(_:)))
            navigationItem.rightBarButtonItem = composeBarButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Inbox"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
    }
}

extension InboxController {
    
    private func manipulateMessengers(accountId: String) {
        for i in messengers {
            if let member = i.members.first(where: {$0 != accountId}) {
                if let account = cachedAccounts.first(where: {$0.id == member}) {
                    i.user = account
                }
            }
        }
        inboxCollectionView.reloadData()
        loadFriendlyLabel()
    }
    
    private func fetchMessages() {
        if isPersonalAccount {
            guard let personal = personalAccount else { return }
            messagesProvider.fetchMessengers(accountId: personal.id).then { (messengers) in
                let memberIds = self.messagesProvider.getMemberIds(accountId: personal.id, messengers: messengers)
                self.messagesProvider.fetchCachedStores(accountIds: memberIds).then { (stores) in
                    self.messengers = messengers
                    self.cachedAccounts = stores
//                    let messengersJson = Mapper().toJSONString(messengers, prettyPrint: true)!
//                    let storesJson = Mapper().toJSONString(stores, prettyPrint: true)!
//                    print("messengersJson: \(messengersJson)")
//                    print("storesJson: \(storesJson)")
                    self.manipulateMessengers(accountId: personal.id)
                }
            }
        } else {
            guard let business = businessAccount else { return }
            messagesProvider.fetchMessengers(accountId: business.id).then { (messengers) in
                let memberIds = self.messagesProvider.getMemberIds(accountId: business.id, messengers: messengers)
                self.messagesProvider.fetchCachedUsers(accountIds: memberIds).then { (users) in
                    self.messengers = messengers
                    self.cachedAccounts = users
//                    let messengersJson = Mapper().toJSONString(messengers, prettyPrint: true)!
//                    let usersJson = Mapper().toJSONString(users, prettyPrint: true)!
//                    print("messengersJson: \(messengersJson)")
//                    print("usersJson: \(usersJson)")
                    self.manipulateMessengers(accountId: business.id)
                }
            }
        }
    }
    
    private func manipulateActivities() {
        for i in activities {
            if let account = cachedSenders.first(where: {$0.id == i.senderId}) {
                i.user = account
            }
        }
        inboxCollectionView.reloadData()
        loadFriendlyLabel()
    }
    
    private func fetchActivities() {
        if isPersonalAccount {
            guard let personal = personalAccount else { return }
            messagesProvider.fetchActivities(accountId: personal.id).then { (results) in
                let senderIds = self.messagesProvider.getSenderIds(activities: results)
                self.messagesProvider.fetchCachedStores(accountIds: senderIds).then { (stores) in
                    self.activities = results
                    self.cachedSenders = stores
                    self.manipulateActivities()
                }
            }
        } else {
            guard let business = businessAccount else { return }
            messagesProvider.fetchActivities(accountId: business.id).then { (results) in
                let senderIds = self.messagesProvider.getSenderIds(activities: results)
                self.messagesProvider.fetchCachedUsers(accountIds: senderIds).then { (users) in
                    self.activities = results
                    self.cachedSenders = users
                    self.manipulateActivities()
                }
            }
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            mainTabBar.isHidden = true
        } else {
            mainTabBar.isHidden = false
        }
    }
    
    func fetchReservation(reservationId: String) -> Promise<Reservation> {
        return Promise<Reservation>(in: .background) { (resolve, reject, _) in
            self.reservationRef.document(reservationId).getDocument { (document, error) in
                if let document = document, document.exists {
                    let record = Mapper<Reservation>().map(JSONObject: document.data())!
                    resolve(record)
                } else {
                    print("Document does not exist")
                    reject(error!)
                }
            }
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
}


extension InboxController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 20
        if selectInbox == 0 {
            return CGSize(width: width, height: 60)
        } else {
            return CGSize(width: width, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectInbox == 0 {
            return messengers.count
        } else {
            return activities.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if selectInbox == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messengerCell, for: indexPath) as! MessengerCell
            cell.messenger = messengers[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: activityCell, for: indexPath) as! ActivityCell
            cell.activity = activities[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectInbox == 0 {
            let controller = MessageController()
            mainTabBar.isHidden = true
            controller.messenger = messengers[indexPath.item]
            navigationController?.pushViewController(controller, animated: true)
        } else if selectInbox == 1 {
            if !isPersonalAccount {
                let activity = activities[indexPath.item]
                fetchReservation(reservationId: activity.reservationId).then { (reservation) in
                    self.presentBizReservation(reservation: reservation)
                }
            }
        }
    }
    
    func didSelectInbox(selectIndex: Int) {
        selectInbox = selectIndex
        for (index, element) in inboxPages.enumerated() {
            if index == selectIndex {
                element.isSelected = true
            } else {
                element.isSelected = false
            }
        }
        fetchSelection()
    }
}
