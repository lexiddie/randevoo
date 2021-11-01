//
//  ReservationController.swift
//  randevoo
//
//  Created by Lex on 8/11/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import MessageKit
import ObjectMapper
import FirebaseFirestore
import Presentr

class DisplayReservation: Codable {
    var reservation: Reservation
    var date: Date?
    
    init(reservation: Reservation, date: Date) {
        self.reservation = reservation
        self.date = date
    }
}

class ReservationController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var mainTabBar: UITabBar!
    
    private var alertHelper = AlertHelper()
    private let db = Firestore.firestore()
    private var userRef: CollectionReference!
    private var businessRef: CollectionReference!
    private var reservationRef: CollectionReference!
    private var timeslotRef: CollectionReference!
    private var bizPeriodRef: CollectionReference!
    let reservationCell = "reservationCell"
    var reservations: [Reservation] = []
    var stores: [BusinessAccount] = []
    var timeslots: [Timeslot] = []
    var reservationsWithDate: [DisplayReservation] = []
    var backupReservation: [DisplayReservation] = []
    var filterString = "Latest"
    private var refreshControl = UIRefreshControl()
    private var reservationCollectionView: UICollectionView!
    private var friendlyLabel: UILabel!
    private var reservationListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.randevoo.mainLight
        setupNavItems()
        initialView()
        initialCollectionView()
        initiateFirestore()
//        fetchRealTimeReservation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let mainTabBarController = self.tabBarController as! MainTabBarController
        mainTabBar = mainTabBarController.tabBar
        mainTabBar.isHidden = false
        fetchRealTimeReservation()
        
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reservationListener.remove()
        print("close reservation")
    }

    
    private func initialView() {
        let view = ReservationView(frame: self.view.frame)
        self.reservationCollectionView = view.reservationCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.view = view
        self.hideKeyboardWhenTappedAround()
    }
    
    private func initialCollectionView() {
        reservationCollectionView.delegate = self
        reservationCollectionView.dataSource = self
        reservationCollectionView.register(ReservationCell.self, forCellWithReuseIdentifier: reservationCell)
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: UIControl.Event.valueChanged)
        reservationCollectionView.addSubview(refreshControl)
        reservationCollectionView.isScrollEnabled = true
        reservationCollectionView.keyboardDismissMode = .onDrag
        loadFriendlyLabel()
    }
    
    @IBAction func refreshList(_ sender: Any?) {
        fetchReservations()
        applyFilter(filter: filterString)
    }
    
    private func initiateFirestore() {
        userRef = db.collection("users")
        businessRef = db.collection("businesses")
        reservationRef = db.collection("reservations")
        timeslotRef = db.collection("timeslots")
        bizPeriodRef = db.collection("bizPeriods")
    }
    
    private func loadFriendlyLabel() {
        if reservationsWithDate.count == 0 {
            friendlyLabel.text = "No reservation is found😴"
        } else {
            friendlyLabel.text = nil
        }
    }
    
    private func fetchReservations(){
        guard let personal = personalAccount else {
            print("Personal Info is empty in reservation")
            return
        }
        reservationRef.whereField("userId", isEqualTo: personal.id!).getDocuments() { (querySnapShot, err) in
            if err != nil {
                print("Failed to Retrieve User Reservation")
            } else {
                for document in querySnapShot!.documents {
                    let currentData = Mapper<Reservation>().map(JSONObject: document.data())
                    if !self.reservations.contains(where: {$0.id == currentData?.id}) {
                        self.reservations.append(currentData!)
                    }
                    self.reservationCollectionView.reloadData()
                    self.loadFriendlyLabel()
                }
                for reservation in self.reservations {
                    if !self.stores.contains(where: {$0.userId == reservation.businessId}) {
                        self.fetchStores(storeId: reservation.businessId)
                    }
                }
                self.retrieveTimeslot()
            }
        }
    }
    
    
    private func fetchRealTimeReservation(){
        guard let personal = personalAccount else {
            print("Personal Info is empty in reservation")
            return
        }
        reservationListener = self.reservationRef.whereField("userId", isEqualTo: personal.id!).addSnapshotListener() { (querySnapShot, err) in
            if err != nil {
                print("Failed to Retrieve User Reservation")
            } else {
                for document in querySnapShot!.documents {
                    let currentData = Mapper<Reservation>().map(JSONObject: document.data())
                    print(currentData?.id)
                    if !self.reservations.contains(where: {$0.id == currentData?.id}) {
                        self.reservations.append(currentData!)
                    } else {
                        let newStatus = currentData?.status
                        for reserve in self.reservations {
                            if currentData?.id == reserve.id && currentData?.status != reserve.status {
                                reserve.status = newStatus
                            }
                        }
                    }
                    self.reservationCollectionView.reloadData()
                    self.loadFriendlyLabel()
                }
                for reservation in self.reservations {
                    if !self.stores.contains(where: {$0.userId == reservation.businessId}) {
                        self.fetchStores(storeId: reservation.businessId)
                    }
                }
                self.retrieveTimeslot()
            }
        }
    }
    
    
    private func fetchStores(storeId: String) {
        businessRef.whereField("id", isEqualTo: storeId).getDocuments() { [self](querySnapShot, err) in
            if err != nil {
                print("Failed to Retrieve Biz Acc")
                self.refreshControl.endRefreshing()
            } else {
                for document in querySnapShot!.documents {
                    let currentData = Mapper<BusinessAccount>().map(JSONObject: document.data())
                    if !stores.contains(where: {$0.id == currentData?.id}) {
                        stores.append(currentData!)
                    }
                }
                self.refreshControl.endRefreshing()
                reservationCollectionView.reloadData()
            }
        }
    }
    
    private func fetchTimeslot(timeslotId: String) {
        timeslotRef.whereField("id", isEqualTo: timeslotId).getDocuments() { [self](querySnapShot, err) in
            if err != nil {
                print("Failed to Retrieve Timeslot")
                self.refreshControl.endRefreshing()
            } else {
                for document in querySnapShot!.documents{
                    let currentData = Mapper<Timeslot>().map(JSONObject: document.data())
                    timeslots.append(currentData!)
                }
                self.refreshControl.endRefreshing()
                bindTimeslotWithReservation()
                applyFilter(filter: filterString)
                reservationCollectionView.reloadData()
            }
        }
    }
    
    private func retrieveTimeslot() {
        if reservations.count > timeslots.count {
            for reserve in reservations {
                if !timeslots.contains(where: {$0.id == reserve.timeslotId}) {
                    fetchTimeslot(timeslotId: reserve.timeslotId)
                }
            }
        }
    }
    
    private func bindTimeslotWithReservation(){
        for reserve in reservations {
            let filterTime = timeslots.filter({$0.id == reserve.timeslotId})
            if filterTime.count != 0 && !reservationsWithDate.contains(where: {$0.reservation.id == reserve.id}) {
                let beginTime = filterTime[0].time.split(separator: "-")
                let dateTime = "\(String(filterTime[0].date))T\(beginTime[0]):00+0000"
                let dateFormatter = ISO8601DateFormatter()
                let date = dateFormatter.date(from:dateTime)!
                let reserveWithDate = DisplayReservation(reservation: reserve, date: date)
                reservationsWithDate.append(reserveWithDate)
                reservationsWithDate = reservationsWithDate.sorted(by: {$0.date!.compare($1.date!) == .orderedDescending})
            }
        }
        backupReservation = reservationsWithDate
        loadFriendlyLabel()
        reservationCollectionView.reloadData()
    }
    
    let presenter: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.fluid(percentage: 0.5)
        let center = ModalCenterPosition.bottomCenter
        let presentr = Presentr(presentationType: .custom(width: width, height: height, center: center))
        presentr.roundCorners = true
        presentr.cornerRadius = 10
        presentr.backgroundColor = UIColor.black
        presentr.backgroundOpacity = 0.7
        presentr.transitionType = .coverVertical
        presentr.dismissTransitionType = .coverVertical
        presentr.dismissOnSwipe = true
        presentr.dismissAnimated = true
        presentr.dismissOnSwipeDirection = .default
        return presentr
    }()
    
    
    @IBAction func handleShowFilter(_ sender: Any){
        let controller = FilterReservationController()
        controller.filterString = filterString
        controller.mainController = self
        customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
    }
    
    @IBAction func handleSave(_ sender: Any?) {
        mainTabBar.isHidden = true
        let likeController = SaveController()
        navigationController?.pushViewController(likeController, animated: true)
    }
    
    @IBAction func handleBag(_ sender: Any?) {
        mainTabBar.isHidden = true
        let listController = ListDetailsController()
        navigationController?.pushViewController(listController, animated: true)
    }
    
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Reservation"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
        
        let sortButton = UIButton(type: .system)
        sortButton.setImage(UIImage(named: "SortIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        sortButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        sortButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        sortButton.contentHorizontalAlignment = .center
        sortButton.contentVerticalAlignment = .center
        sortButton.contentMode = .scaleAspectFit
        sortButton.backgroundColor = UIColor.clear
        sortButton.layer.cornerRadius = 8
        sortButton.addTarget(self, action: #selector(handleShowFilter(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: sortButton)
        sortButton.snp.makeConstraints{ (make) in
           make.height.width.equalTo(40)
        }
        
        let bagBarButton = UIBarButtonItem(image: UIImage(named: "BagIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBag(_:)))
        let saveBarButton = UIBarButtonItem(image: UIImage(named: "LikedIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSave(_:)))
        navigationItem.rightBarButtonItems = [bagBarButton, saveBarButton]
    }
    
    func applyFilter(filter: String) {
        if filter == "Latest" {
            reservationsWithDate = backupReservation.sorted(by: {$0.date!.compare($1.date!) == .orderedDescending})
        } else if filter == "Earliest" {
            reservationsWithDate = backupReservation.sorted(by: {$0.date!.compare($1.date!) == .orderedAscending})
        } else if filter == "Completed" {
            reservationsWithDate = backupReservation.filter({$0.reservation.status == "Completed"})
        } else if filter == "Approved" {
            reservationsWithDate = backupReservation.filter({$0.reservation.status == "Approved"})
        } else if filter == "Failed" {
            reservationsWithDate = backupReservation.filter({$0.reservation.status == "Failed"})
        } else if filter == "Pending" {
            reservationsWithDate = backupReservation.filter({$0.reservation.status == "Pending"})
        }
        loadFriendlyLabel()
        filterString = filter
        reservationCollectionView.reloadData()
    }
}

extension ReservationController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 2
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
        return reservationsWithDate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reservationCell, for: indexPath) as! ReservationCell
        if reservationsWithDate[indexPath.row].reservation.status.lowercased() == "completed" {
            cell.status.textColor = UIColor.randevoo.mainStatusGreen
            cell.barView.backgroundColor = UIColor.randevoo.mainStatusGreen
        } else if reservationsWithDate[indexPath.row].reservation.status.lowercased() == "approved" {
            cell.status.textColor = UIColor.randevoo.mainColor
            cell.barView.backgroundColor = UIColor.randevoo.mainColor
        } else if reservationsWithDate[indexPath.row].reservation.status.lowercased() == "failed" {
            cell.status.textColor = UIColor.randevoo.mainStatusRed
            cell.barView.backgroundColor = UIColor.randevoo.mainStatusRed
        } else if reservationsWithDate[indexPath.row].reservation.status.lowercased() == "pending" {
            cell.status.textColor = UIColor.randevoo.mainStatusYellow
            cell.barView.backgroundColor = UIColor.randevoo.mainStatusYellow
        } else if reservationsWithDate[indexPath.row].reservation.status.lowercased() == "declined" {
            cell.status.textColor = UIColor.randevoo.mainStatusRed
            cell.barView.backgroundColor = UIColor.randevoo.mainStatusRed
        } else if reservationsWithDate[indexPath.row].reservation.status.lowercased() == "canceled" {
            cell.status.textColor = UIColor.randevoo.mainStatusRed
            cell.barView.backgroundColor = UIColor.randevoo.mainStatusRed
        }
        let width = (view.frame.width - 5) / 16
        
        cell.shopImg.layer.cornerRadius = width
        cell.status.text = reservationsWithDate[indexPath.row].reservation.status
        cell.reservationID.text = "ID: " + reservationsWithDate[indexPath.row].reservation.qrCode
        cell.reservationItem.text = "Total Items: " + String(reservationsWithDate[indexPath.row].reservation.products.count) + " Types"
        let selectedTimeSlot = timeslots.filter({$0.id == reservationsWithDate[indexPath.row].reservation.timeslotId})
        let selectedBiz = stores.filter({$0.id == reservationsWithDate[indexPath.row].reservation.businessId})
        if selectedTimeSlot.count != 0 {
            cell.time.text = selectedTimeSlot[0].time
            let dateSplit = selectedTimeSlot[0].date.split(separator: "-")
            let monthName = DateFormatter().monthSymbols[Int(dateSplit[1])! - 1]
            let dateForm = "\(monthName) \(dateSplit[2]), \n\(dateSplit[0])"
            cell.dateLabel.text = dateForm
        }
        if selectedBiz.count != 0  {
            if selectedBiz[0].profileUrl != "" {
                cell.shopImg.loadCacheImage(urlString: selectedBiz[0].profileUrl)
            }else {
                cell.shopImg.image =  UIImage(named: "ProfileIcon")!
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reservationDetail = ReservationDetailController()
        reservationDetail.hidesBottomBarWhenPushed = true
        reservationDetail.reserveProduct = reservationsWithDate[indexPath.row].reservation
        let selectedTimeSlot = timeslots.filter({$0.id == reservationsWithDate[indexPath.row].reservation.timeslotId})
        let selectedBiz = stores.filter({$0.id == reservationsWithDate[indexPath.row].reservation.businessId})
        if selectedTimeSlot.count != 0 {
            reservationDetail.timeslot = selectedTimeSlot[0]
        }
        if selectedBiz.count != 0 {
            reservationDetail.storeAccount = selectedBiz[0]
        }
        navigationController?.pushViewController(reservationDetail, animated: true)
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
