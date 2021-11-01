//
//  CreateBizAccountController.swift
//  randevoo
//
//  Created by Lex on 23/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON
import FirebaseFirestore
import FirebaseStorage
import AlamofireImage
import Hydra

class CreateBizAccountController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {

    var previousController: UIViewController!
    
    private var alertHelper = AlertHelper()
    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
    private var businessRef: CollectionReference!
    private var bizPeriodRef: CollectionReference!
    private var bizInfoRef: CollectionReference!
    private let timestampHelper = TimestampHelper()
    private let usersProvider = UsersProvider()
    private let devicesProvider = DevicesProvider()
    private let switchProvider = SwitchProvider()
    private var alertController: UIAlertController!
    
    var businessName: String!
    var websiteUrl: String!
    var location: String!
    var geoPoint: GeoPoint!
    var businessType: String!
    var businessAbout: String!
    
    var scrollView: UIScrollView!
    var businessTypeTextField: UITextField!
    var aboutTextView: UITextView!
    
    var businessHours: [BusinessHour] = [BusinessHour(businessDate: .sun, openTime: "09:00", closeTime: "18:00", isActive: true),
                                         BusinessHour(businessDate: .mon, openTime: "09:00", closeTime: "18:00", isActive: true),
                                         BusinessHour(businessDate: .tue, openTime: "09:00", closeTime: "18:00", isActive: true),
                                         BusinessHour(businessDate: .wed, openTime: "09:00", closeTime: "18:00", isActive: true),
                                         BusinessHour(businessDate: .thu, openTime: "09:00", closeTime: "18:00", isActive: true),
                                         BusinessHour(businessDate: .fri, openTime: "09:00", closeTime: "18:00", isActive: true),
                                         BusinessHour(businessDate: .sat, openTime: "09:00", closeTime: "18:00", isActive: true)]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initiateFirestore()
    }
    
    private func initialView() {
        self.view.backgroundColor = UIColor.randevoo.mainLight
        let view = CreateBizAccountView(frame: self.view.frame)
        self.scrollView = view.scrollView
        self.businessTypeTextField = view.businessTypeTextField
        self.aboutTextView = view.aboutTextView
        self.view = view
        self.scrollView.delegate = self
        self.businessTypeTextField.delegate = self
        self.aboutTextView.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    private func initiateFirestore() {
        bizInfoRef = db.collection("bizInfos")
        bizPeriodRef = db.collection("bizPeriods")
        businessRef = db.collection("businesses")
    }
    
    private func getBizHours() -> [BizHour] {
        var tempBizHours: [BizHour] = []
        for i in businessHours {
            let current = BizHour(dateLabel: i.businessDate.rawValue, openTime: i.openTime, closeTime: i.closeTime, isActive: i.isActive)
            tempBizHours.append(current)
        }
        return tempBizHours
    }
    
    private func getBizRange() -> Period {
        let current = BusinessRange(rangeType: .week, dateRange: .oneWeek, value: 7)
        return Period(label: current.dateRange.rawValue, value: current.value)
    }
    
    private func getBizTimeslot() -> Period {
        let current = BusinessTimeslot(timeRange: .halfHour, value: 0.5)
        return Period(label: current.timeRange.rawValue, value: current.value)
    }
    
    private func getBizAvailability() -> Period {
        let current = BusinessAvailability(label: "1 Time", value: 1)
        return Period(label: current.label, value: current.value)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.randevoo.mainLightGray.withAlphaComponent(0.8) {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "A little description about your business"
            textView.textColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.8)
        }
    }

    private func checkDescriptionIsValid() -> String {
        if aboutTextView.textColor == UIColor.randevoo.mainLightGray.withAlphaComponent(0.8) {
            print("Empty")
            return ""
        } else {
            print("Not empty")
            return aboutTextView.text! as String
        }
    }
    
    @IBAction func handleCreate(_ sender: Any?) {
        if (businessTypeTextField.text?.isEmpty)! {
            alertHelper.showAlert(title: "Invalid Input", alert: "Your business type must be selected!", controller: self)
        } else {
            alertController = displaySpinner()
            print("Creating a business account is valid")
            businessAbout = checkDescriptionIsValid()
            let _ = async { (_) -> (BusinessAccount, Bool, Bool) in
                let generatedUsername = try await(self.usersProvider.findUsernameViaName(name: self.businessName))
                let businessAccount = try await(self.createBusinessAccount(username: generatedUsername, country: "Thailand"))
                let checkBizInfo = try await(self.createBusinessInfo(businessId: businessAccount.id, about: self.businessAbout!, geoPoint: self.geoPoint))
                let checkBizPeriod = try await(self.createBizPeriod(businessId: businessAccount.id))
                return (businessAccount, checkBizInfo, checkBizPeriod)
            }.then { (businessAccount, _, _) in
                self.validateAccountStatus(business: businessAccount)
                print("Business Account has been created successfully")
            }
        }
    }
    
    private func validateAccountStatus(business: BusinessAccount) {
        let settingController = previousController as! SettingController
        self.devicesProvider.validateDeviceToken(accountId: business.id)
        self.switchProvider.startSwitchAccount(mainTabBarController: settingController.mainTabBarController, accountId: business.id, isPersonal: false)
        self.navigationController?.dismiss(animated: true, completion: {
            settingController.dismiss(animated: true)
        })
    }
    
    private func createBusinessAccount(username: String, country: String) -> Promise<BusinessAccount> {
        let businessId = businessRef.document().documentID
        let businessAccount = BusinessAccount(id: businessId, userId: (personalAccount?.id)!, name: businessName, type: businessType!, username: username, country: country, location: location, website: websiteUrl,createdAt: Date().iso8601withFractionalSeconds)
        return Promise<BusinessAccount>(in: .background) { (resolve, reject, _) in
            self.businessRef.document(businessId).setData(businessAccount.toJSON()) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.alertController.dismiss(animated: true, completion: nil)
                    reject(err)
                } else {
                    print("Document successfully written!")
                    FCache.set(businessAccount, key: "business")
                    print("Added Business Account Into Cache In CreateBizAccountController")
                    let businessJson = Mapper().toJSONString(businessAccount, prettyPrint: true)!
                    print("Business Account: \(businessJson)")
                    resolve(businessAccount)
                }
            }
        }
    }
    
    private func createBusinessInfo(businessId: String, about: String, geoPoint: GeoPoint) -> Promise<Bool> {
        let bizInfoId = bizInfoRef.document().documentID
        let bizInfo = BizInfo(id: bizInfoId, businessId: businessId, about: about, geoPoint: geoPoint, createdAt: Date().iso8601withFractionalSeconds, isCurrent: true)
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.bizInfoRef.document(bizInfoId).setData(bizInfo.toJSON()) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.alertController.dismiss(animated: true, completion: nil)
                    resolve(false)
                } else {
                    print("Document successfully written!")
                    FCache.set(bizInfo, key: "bizInfo")
                    print("Added Business Info Into Cache In CreateBizAccountController")
                    self.alertController.dismiss(animated: true, completion: nil)
                    resolve(true)
                }
            }
        }
    }
    
    private func createBizPeriod(businessId: String) -> Promise<Bool>  {
        let bizPeriodId = bizPeriodRef.document().documentID
        let bizHours = getBizHours()
        let bizRange = getBizRange()
        let bizTimeslot = getBizTimeslot()
        let bizAvailability = getBizAvailability()
        let bizPeriod = BizPeriod(id: bizPeriodId, businessId: businessId, bizHours: bizHours, bizRange: bizRange, bizTimeslot: bizTimeslot, bizAvailability: bizAvailability, createdAt: Date().iso8601withFractionalSeconds)
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.bizPeriodRef.document(bizPeriodId).setData(bizPeriod.toJSON()) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    resolve(false)
                } else {
                    print("BizPeriod has been written successfully!")
                    resolve(true)
                }
            }
        }
    }
    
    @IBAction func handleSearchType(_ sender: Any?) {
        let controller = BizTypeController()
        controller.previousController = self
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Create business account"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
        
        let backBarButton = UIBarButtonItem(image: UIImage(named: "ArrowLeft")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss(_:)))
        navigationItem.leftBarButtonItem = backBarButton
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    }
}
