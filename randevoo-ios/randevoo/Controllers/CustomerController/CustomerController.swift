//
//  CustomerController.swift
//  randevoo
//
//  Created by Lex on 31/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON
import FirebaseAuth
import FirebaseFirestore
import Hydra

class CustomerController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var userId: String!
    
    private var user: User?
    private var mainSiteUrl: String! = ""
    
    private let customerProfileCell = "customerProfileCell"
    
    private let alert = AlertHelper()
    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
    private var userRef: CollectionReference!
    private var messagesProvider = MessagesProvider()
    private var messenger: Messenger!

    private var customerCollectionView: UICollectionView!
    private var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems();
        initialView()
        initialCollectionView()
        initiateFirestore()
        fetchUserAccount()
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
        userRef = db.collection("users")
    }
    
    private func displayInfo() {
        if personalAccount?.website != "" {
            mainSiteUrl = personalAccount?.website
        }
        updateProfile()
        customerCollectionView.reloadData()
    }
    
    private func fetchUserAccount() {
        guard let _ = user else {
            userRef.document(userId).getDocument { (document, error) in
                if let document = document, document.exists {
                    let record = Mapper<User>().map(JSONObject: document.data())!
                    self.user = record
                    self.displayInfo()
                } else {
                    print("Document does not exist")
                }
            }
            return
        }
        self.displayInfo()
    }
    
    private func updateProfile() {
        guard let user = user else { return }
        if user.website != "" {
            mainSiteUrl = user.website
        }
        
        titleLabel = UILabel()
        titleLabel.text = user.username
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
    }
    
    private func initialView() {
        let view = CustomerView(frame: self.view.frame)
        self.customerCollectionView = view.customerCollectionView
        self.view = view
    }
    
    private func initialCollectionView() {
        customerCollectionView.delegate = self
        customerCollectionView.dataSource = self
        customerCollectionView.register(CustomerProfileCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: customerProfileCell)
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
    
    @IBAction func handleSite(_ sender: Any?) {
        guard let url = URL(string: "https://\(String(mainSiteUrl))") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    private func pushMessageController(messenger: Messenger) {
        let controller = MessageController()
        controller.messenger = messenger
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleMessage(_ sender: Any?) {
        let accountId = getAccountId()
        messagesProvider.checkMessenger(accountId: accountId, memberId: self.userId).then { (check) in
            if check {
                self.messenger = self.messagesProvider.messenger
                let json = Mapper().toJSONString(self.messenger, prettyPrint: true)!
                print("Member is existed, : \(json)")
                self.pushMessageController(messenger: self.messenger)
            } else {
                self.messagesProvider.createMessenger(accountId: accountId, memberId: self.userId).then { (messenger) in
                    self.messenger = messenger
                    let json = Mapper().toJSONString(messenger, prettyPrint: true)!
                    print("Messenger is created, : \(json)")
                    self.pushMessageController(messenger: messenger)
                }
            }
        }
    }
    
    private func enableMessage() {
        if !isPersonalAccount {
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


extension CustomerController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: customerProfileCell, for: indexPath) as! CustomerProfileCell
        header.user = user
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 390)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        guard let user = user else { return CGSize(width: width, height: width) }
        let font = UIFont(name: "Quicksand-Medium", size: 17)!
        let bioWidth = view.frame.width - 40
        var heightOfText = 0.0 as Float
        if user.bio != "" {
            heightOfText = Float(user.bio.heightWithConstrainedWidth(width: bioWidth, font: font))
        }
        var currentHeight: Float = 240
        if user.website != "" {
            currentHeight += 25
        }
        if user.location != "" {
            currentHeight += 25
        }
        return CGSize(width: width, height: CGFloat(currentHeight + heightOfText) + 5)
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
