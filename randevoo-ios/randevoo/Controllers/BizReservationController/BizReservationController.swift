//
//  BizReservationController.swift
//  randevoo
//
//  Created by Lex on 28/2/21.
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

class ReservedPage: NSObject {
    let label: String
    var isSelected: Bool

    init(label: String, isSelected: Bool) {
        self.label = label
        self.isSelected = isSelected
    }
}

class BizReservationController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BizReservedSelectionViewDelegate, BizCalendarViewDelegate {

    private var alertHelper = AlertHelper()
    private let db = Firestore.firestore()
    private var userRef: CollectionReference!
    private var reservationRef: CollectionReference!
    private var timeslotRef: CollectionReference!
    private var bizPeriodRef: CollectionReference!
    private let timestampHelper = TimestampHelper()
    private var alertController: UIAlertController!
    
    private var reservedPages: [ReservedPage] = [ReservedPage(label: "Customers", isSelected: true),
                                                 ReservedPage(label: "Calendar", isSelected: false)]
        
    private let bizReservationCell = "bizReservationCell"
    private let reservedCustomerCell = "reservedCustomerCell"
    
    private var cachedUsers: [User] = []
    private var cachedTimeslots: [Timeslot] = []
    private var bizReservations: [BizReservation] = []
    private var selectReserved = 0
    private var bizReservationCollectionView: UICollectionView!
    private var friendlyLabel: UILabel!
    
    private lazy var bizReservedPageView: BizReservedPageView = {
        let view = BizReservedPageView()
        view.reservedPages = self.reservedPages
        view.delegate = self
        return view
    }()
    
    private lazy var bizCalendarView: BizCalendarView = {
        let view = BizCalendarView()
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
        bizReservedPageView.animateBar(index: selectReserved, duration: 0.4)
        fetchSelection()
        
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func initialView() {
        let view = BizReservationView(frame: self.view.frame)
        self.bizReservationCollectionView = view.bizReservationCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.view = view
        self.view.addSubview(bizReservedPageView)
        bizReservedPageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(40)
            make.centerX.equalTo(self.view)
            make.left.right.lessThanOrEqualTo(self.view)
        }
        self.view.addSubview(bizCalendarView)
        bizCalendarView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(40)
            make.centerX.equalTo(self.view)
            make.left.right.lessThanOrEqualTo(self.view)
            make.bottom.equalTo(self.view)
        }
        self.hideKeyboardWhenTappedAround()
    }
    
    private func initialCollectionView() {
        bizReservationCollectionView.delegate = self
        bizReservationCollectionView.dataSource = self
        bizReservationCollectionView.register(BizReservationCell.self, forCellWithReuseIdentifier: bizReservationCell)
        bizReservationCollectionView.register(ReservedCustomerCell.self, forCellWithReuseIdentifier: reservedCustomerCell)
        bizReservationCollectionView.isScrollEnabled = true
        bizReservationCollectionView.keyboardDismissMode = .onDrag
    }
    
    private func initiateFirestore() {
        userRef = db.collection("users")
        reservationRef = db.collection("reservations")
        timeslotRef = db.collection("timeslots")
        bizPeriodRef = db.collection("bizPeriods")
    }
    
    private func loadFriendlyLabel() {
        if selectReserved == 0 && bizReservations.count == 0 {
            friendlyLabel.text = "No customers in reservation to show😴"
        } else {
            friendlyLabel.text = nil
        }
    }
    
    private func fetchSelection() {
        loadFriendlyLabel()
        if selectReserved == 0 {
            bizCalendarView.isHidden = true
            fetchReservations().then { (reservations) in
                self.fetchReservedData(reservations: reservations)
            }
        } else if selectReserved == 1 {
            fetchBizPeriod().then { (check) in
                if check {
                    self.bizCalendarView.isHidden = false
                    self.bizCalendarView.timeslotCollectionView.reloadData()
                    self.bizCalendarView.loadFriendlyLabel()
                    self.loadFriendlyLabel()
                } else {
                    self.bizCalendarView.isHidden = true
                }
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
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Reservation"
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

    }
    
    
}

extension BizReservationController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: 175)
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
        return bizReservations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if selectReserved == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reservedCustomerCell, for: indexPath) as! ReservedCustomerCell
            cell.reservation = bizReservations[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bizReservationCell, for: indexPath) as! BizReservationCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectReserved == 0 {
            let controller = ReservedProductController()
            controller.isFromBizReservation = true
            controller.bizReservation = bizReservations[indexPath.item]
            navigationController?.pushViewController(controller, animated: true)
        } else if selectReserved == 1 {
            
        }
    }
    
    func didSelectReseved(selectIndex: Int) {
        selectReserved = selectIndex
        for (index, element) in reservedPages.enumerated() {
            if index == selectIndex {
                element.isSelected = true
            } else {
                element.isSelected = false
            }
        }
        fetchSelection()
    }
    
    func didSelectOnTimeslot(indexSlot: Int) {
        
    }
}


extension BizReservationController {
    
    private func fetchReservedData(reservations: [Reservation]) {
        let timeslotId = getTimeslotIds(reservations: reservations)
        let userIds = getUserIds(reservations: reservations)
        let _ = async { (_) -> ([Timeslot], [User]) in
            let timeslots = try await(self.fetchTimeslots(timeslotIds: timeslotId))
            let users = try await(self.fetchUsers(userIds: userIds))
            return (timeslots, users)
        }.then { (timeslots, users) in
            self.bizCalendarView.timeslots = timeslots
            self.bizCalendarView.bizReservations = self.bizReservations
            self.bizCalendarView.mainController = self
            self.bizCalendarView.retrieveDate()
            self.cachedTimeslots = timeslots
            self.cachedUsers = users
            self.fetchBizReservations(reservations: reservations)
            //            let resultJson = Mapper().toJSONString(self.bizReservations, prettyPrint: true)!
            //            print("\nBizReservations: \(resultJson)")
        }
    }
    
    private func fetchBizReservations(reservations: [Reservation]) {
        bizReservations.removeAll()
        var tempList: [BizReservation] = []
        for (_, element) in reservations.enumerated() {
            if let timeslot = cachedTimeslots.first(where: {$0.id == element.timeslotId}) {
                if let user = cachedUsers.first(where: {$0.id == element.userId}) {
                    let current = BizReservation(reservation: element, user: user, timeslot: timeslot)
                    tempList.append(current)
                }
            }
        }
        bizReservations = tempList
        bizReservationCollectionView.reloadData()
        loadFriendlyLabel()
    }
    
    private func fetchUsers(userIds: [String]) -> Promise<[User]> {
        return Promise<[User]>(in: .background) { (resolve, reject, _) in
            var tempList: [User] = []
            for (_, element) in userIds.enumerated() {
                self.userRef.document(element).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let result = Mapper<User>().map(JSONObject: document.data())!
                        tempList.append(result)
                    } else {
                        print("Document does not exist")
                    }
                    
                    if tempList.count == userIds.count {
                        resolve(tempList)
                    }
                }
            }
        }
    }
    
    private func fetchTimeslots(timeslotIds: [String]) -> Promise<[Timeslot]> {
        return Promise<[Timeslot]>(in: .background) { (resolve, reject, _) in
            var tempList: [Timeslot] = []
            for (_, element) in timeslotIds.enumerated() {
                self.timeslotRef.document(element).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let result = Mapper<Timeslot>().map(JSONObject: document.data())!
                        tempList.append(result)
                    } else {
                        print("Document does not exist")
                    }
                    
                    if tempList.count == timeslotIds.count {
                        resolve(tempList)
                    }
                }
            }
        }
    }
    
    private func getUserIds(reservations: [Reservation]) -> [String] {
        var tempList: [String] = []
        for i in reservations {
            if !tempList.contains(where: {$0 == i.userId}){
                tempList.append(i.userId)
            }
        }
        return tempList
    }
    
    private func getTimeslotIds(reservations: [Reservation]) -> [String] {
        var tempList: [String] = []
        for i in reservations {
            if !tempList.contains(where: {$0 == i.timeslotId}){
                tempList.append(i.timeslotId)
            }
        }
        return tempList
    }
    
    private func fetchReservations() -> Promise<[Reservation]> {
        return Promise<[Reservation]>(in: .background) { (resolve, reject, _) in
            guard let business = businessAccount else {
                resolve([])
                return
            }
            self.reservationRef
                .whereField("businessId", isEqualTo: business.id as Any)
                .order(by: "createdAt", descending: true)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting category documents: \(err)")
                        reject(err)
                    } else {
                        var tempList: [Reservation] = []
                        for document in querySnapshot!.documents {
                            let result = Mapper<Reservation>().map(JSONObject: document.data())!
                            tempList.append(result)
                        }
                        resolve(tempList)
                    }
                }
        }
        
    }
    
}
