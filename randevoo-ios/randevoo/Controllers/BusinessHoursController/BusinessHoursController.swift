//
//  BusinessHoursController.swift
//  randevoo
//
//  Created by Alexander on 4/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//


import UIKit
import Presentr
import ObjectMapper
import SwiftyJSON
import FirebaseFirestore
import Hydra
import CryptoSwift

class BusinessHour: NSObject {
    let businessDate: BusinessDate
    var openTime: String
    var closeTime: String
    var isActive: Bool

    init(businessDate: BusinessDate, openTime: String, closeTime: String, isActive: Bool) {
        self.businessDate = businessDate
        self.openTime = openTime
        self.closeTime = closeTime
        self.isActive = isActive
    }
}

class BusinessRange: NSObject {
    var rangeType: RangeType
    var dateRange: DateRange
    var value: Double
    
    init(rangeType: RangeType, dateRange: DateRange, value: Double) {
        self.rangeType = rangeType
        self.dateRange = dateRange
        self.value = value
    }
}

class BusinessTimeslot: NSObject {
    var timeRange: TimeRange
    var value: Double
    
    init(timeRange: TimeRange, value: Double) {
        self.timeRange = timeRange
        self.value = value
    }
}

class BusinessAvailability: NSObject {
    var label: String
    var value: Double
    
    init(label: String, value: Double) {
        self.label = label
        self.value = value
    }
}

class BusinessHoursController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BusinessHoursCellDelegate {

    private var alertHelper = AlertHelper()
    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
    private var bizPeriodRef: CollectionReference!
    private let timestampHelper = TimestampHelper()
    private var alertController: UIAlertController!
    private var previousHash: String = ""
    
    var currentBizPeriod: BizPeriod!
    
    let businessCalendarCell = "businessCalendarCell"
    let businessHoursCell = "businessHoursCell"
    
    var refreshControl = UIRefreshControl()
    var businessHoursCollectionView: UICollectionView!
    var businessHourPicker: UIDatePicker = UIDatePicker()
    
    let presenter: Presentr = {
        let presentr = Presentr(presentationType: .bottomHalf)
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
    
    var businessHours: [BusinessHour] = [BusinessHour(businessDate: .sun, openTime: "09:00", closeTime: "18:00", isActive: true),
                                         BusinessHour(businessDate: .mon, openTime: "09:00", closeTime: "18:00", isActive: true),
                                         BusinessHour(businessDate: .tue, openTime: "09:00", closeTime: "18:00", isActive: true),
                                         BusinessHour(businessDate: .wed, openTime: "09:00", closeTime: "18:00", isActive: true),
                                         BusinessHour(businessDate: .thu, openTime: "09:00", closeTime: "18:00", isActive: true),
                                         BusinessHour(businessDate: .fri, openTime: "09:00", closeTime: "18:00", isActive: true),
                                         BusinessHour(businessDate: .sat, openTime: "09:00", closeTime: "18:00", isActive: true)]
    
    var businessRanges: [BusinessRange] = [BusinessRange(rangeType: .week, dateRange: .oneWeek, value: 7),
                                           BusinessRange(rangeType: .week, dateRange: .twoWeek, value: 14),
                                           BusinessRange(rangeType: .week, dateRange: .threeWeek, value: 21),
                                           BusinessRange(rangeType: .month, dateRange: .oneMonth, value: 1),
                                           BusinessRange(rangeType: .month, dateRange: .twoMonth, value: 2),
                                           BusinessRange(rangeType: .month, dateRange: .threeMonth, value: 3)]
    
    var businessTimeslots: [BusinessTimeslot] = [BusinessTimeslot(timeRange: .halfHour, value: 0.5),
                                                BusinessTimeslot(timeRange: .oneHour, value: 1),
                                                BusinessTimeslot(timeRange: .twoHour, value: 2),
                                                BusinessTimeslot(timeRange: .threeHour, value: 3),
                                                BusinessTimeslot(timeRange: .fourHour, value: 4),
                                                BusinessTimeslot(timeRange: .fiveHour, value: 5),
                                                BusinessTimeslot(timeRange: .sixHour, value: 6)]
    
    var businessAvailabilities: [BusinessAvailability] = [BusinessAvailability(label: "1 Time", value: 1),
                                                          BusinessAvailability(label: "2 Times", value: 2),
                                                          BusinessAvailability(label: "3 Times", value: 3),
                                                          BusinessAvailability(label: "4 Times", value: 4),
                                                          BusinessAvailability(label: "5 Times", value: 5)]
    
    func didSelectDate(for cell: BusinessHoursCell) {
        guard let indexPath = businessHoursCollectionView?.indexPath(for: cell) else { return }
        let businessHour = businessHours[indexPath.item]
        businessHour.isActive = !businessHour.isActive
        let bizHour = currentBizPeriod.bizHours[indexPath.item]
        bizHour.isActive = !bizHour.isActive
        self.currentBizPeriod.bizHours[indexPath.item] = bizHour
        self.businessHours[indexPath.item] = businessHour
        self.businessHoursCollectionView?.reloadItems(at: [indexPath])
    }
    
    func didOpenHour(for cell: BusinessHoursCell) {
        guard let indexPath = businessHoursCollectionView?.indexPath(for: cell) else { return }
        let businessHour = businessHours[indexPath.item]
        presentHourSelection(indexPath: indexPath.item, businessHour: businessHour, isOpen: true)
    }
    
    func didCloseHour(for cell: BusinessHoursCell) {
        guard let indexPath = businessHoursCollectionView?.indexPath(for: cell) else { return }
        let businessHour = businessHours[indexPath.item]
        presentHourSelection(indexPath: indexPath.item, businessHour: businessHour, isOpen: false)
    }
    
    private func presentHourSelection(indexPath: Int, businessHour: BusinessHour, isOpen: Bool) {
        let controller = HourSelectionController()
        controller.previousController = self
        controller.indexPath = indexPath
        controller.isOpen = isOpen
        controller.openTime = businessHour.openTime
        controller.closeTime = businessHour.closeTime
        let navController = UINavigationController(rootViewController: controller)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.barTintColor = UIColor.clear
        navController.navigationBar.isHidden = false
        customPresentViewController(presenter, viewController: navController, animated: true, completion: nil)
    }
    
    private func presentNavPickerSelection(selection: Int) {
        let controller = PickerSelectionController()
        controller.previousController = self
        controller.bizPeriod = currentBizPeriod
        if selection == 1 {
            controller.isBusinessRange = true
            controller.businessRanges = businessRanges
        } else if selection == 2 {
            controller.isBusinessTimeslot = true
            controller.businessTimeslots = businessTimeslots
        } else if selection == 3 {
            controller.isBusinessAvailability = true
            controller.businessAvailabilities = businessAvailabilities
        }
        let navController = UINavigationController(rootViewController: controller)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.barTintColor = UIColor.clear
        navController.navigationBar.isHidden = false
        customPresentViewController(presenter, viewController: navController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialCollectionView()
        initiateFirestore()
        getGlobalBizPeriod()
        fetchBizPeriod()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshControl.endRefreshing()
    }
    
    private func initiateFirestore() {
        bizPeriodRef = db.collection("bizPeriods")
    }
    
    private func initialView() {
        let view = BusinessHoursView(frame: self.view.frame)
        self.businessHoursCollectionView = view.businessHoursCollectionView
        self.view = view
    }
    
    private func initialCollectionView() {
        businessHoursCollectionView.delegate = self
        businessHoursCollectionView.dataSource = self
        businessHoursCollectionView.register(BusinessCalendarCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: businessCalendarCell)
        businessHoursCollectionView.register(BusinessHoursCell.self, forCellWithReuseIdentifier: businessHoursCell)
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: UIControl.Event.valueChanged)
        businessHoursCollectionView.addSubview(refreshControl)
    }
    
    private func facilitateBusinessHours() {
        let bizHours = currentBizPeriod.bizHours
        for (index, element) in businessHours.enumerated() {
            if let bizHour = bizHours.first(where: {$0.dateLabel == element.businessDate.rawValue}) {
                businessHours[index] = BusinessHour(businessDate: element.businessDate, openTime: bizHour.openTime, closeTime: bizHour.closeTime, isActive: bizHour.isActive)
            }
        }
        businessHoursCollectionView.reloadData()
    }
    
    private func getGlobalBizPeriod() {
        guard let period = gBizPeriod else { return }
        self.currentBizPeriod = period.copy()
        self.previousHash = period.hashDataObject()
        self.businessHoursCollectionView.reloadData()
        self.facilitateBusinessHours()
        self.refreshControl.endRefreshing()
    }
    
    private func fetchBizPeriod() {
        guard let business = businessAccount else { return }
        bizPeriodRef
            .whereField("businessId", isEqualTo: (business.id)!)
            .limit(to: 1)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let record = Mapper<BizPeriod>().map(JSONObject: document.data())!
                        self.currentBizPeriod = record
                        self.previousHash = record.hashDataObject()
                        self.businessHoursCollectionView.reloadData()
                        self.facilitateBusinessHours()
                        self.refreshControl.endRefreshing()
                    }
                }
            }
    }
    
    private func updateBizPeriod() -> Promise<Bool> {
        alertController = displayFullSpinner()
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.bizPeriodRef.document(self.currentBizPeriod.id).updateData(self.currentBizPeriod.toJSON()) { err in
                if let err = err {
                    print("Updated BizPeriod is error: \(err)")
                    resolve(false)
                } else {
                    print("Updated BizPeriod is completed")
                    resolve(true)
                }
            }
        }
    }
    
    @IBAction func refreshList(_ sender: Any?) {
        fetchBizPeriod()
    }
    
    @IBAction func handleDateRange(_ sender: Any?) {
        presentNavPickerSelection(selection: 1)
    }
    
    @IBAction func handleDuration(_ sender: Any?) {
        presentNavPickerSelection(selection: 2)
    }
    
    @IBAction func handleAvailability(_ sender: Any?) {
        presentNavPickerSelection(selection: 3)
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleDone(_ sender: Any?) {
        let current = currentBizPeriod.hashDataObject()
        if previousHash == current {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            alertHelper.showAlertWithWarningForBizHour(title: "Notice", alert: "Note: this update will not make any effect on the booked reservation, which mean business owner have to cancel it by themselves if they want to. ", controller: self)
        }
    }
    
    func updateBizHour() {
        updateBizPeriod().then { (check) in
            if check {
                gBizPeriod = self.currentBizPeriod
            }
            self.alertController.dismiss(animated: true) {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Business Hours"
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
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone(_:)))
        doneBarButton.tintColor = UIColor.randevoo.mainColor
        navigationItem.rightBarButtonItem = doneBarButton
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    }
    
}


extension BusinessHoursController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: businessCalendarCell, for: indexPath) as! BusinessCalendarCell
        header.bizPeriod = currentBizPeriod
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 650)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return businessHours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: businessHoursCell, for: indexPath) as! BusinessHoursCell
        cell.businessHour = businessHours[indexPath.item]
        cell.delegate = self
        return cell
    }
}
