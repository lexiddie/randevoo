//
//  BizInfoController.swift
//  randevoo
//
//  Created by Lex on 2/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON
import FirebaseFirestore
import FirebaseStorage
import AlamofireImage
import Hydra
import GoogleMaps

class BizInfoController: UIViewController {

    var currentBizInfo: BizInfo!
    
    private var alertHelper = AlertHelper()
    private let db = Firestore.firestore()
    private var bizInfoRef: CollectionReference!
    private var alertController: UIAlertController!
    private var previousHash: String = ""
    
    var phone: String! = ""
    var email: String! = ""
    var about: String! = ""
    var policy: String! = ""
    var geoPoint: GeoPoint!
    
    private var phoneTextField: UITextField!
    private var emailTextField: UITextField!
    private var aboutTextView: UITextView!
    private var policyTextView: UITextView!
    private var locationPickerImageView: UIImageView!

    private var googleMapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initiateFirestore()
        getGlobalBizPeriod()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func initialView() {
        let view = BizInfoView(frame: self.view.frame)
        self.phoneTextField = view.phoneTextField
        self.emailTextField = view.emailTextField
        self.aboutTextView = view.aboutTextView
        self.policyTextView = view.policyTextView
        self.googleMapView = view.googleMapView
        self.locationPickerImageView = view.locationPickerImageView
        self.view = view
    }
    
    private func initiateFirestore() {
        bizInfoRef = db.collection("bizInfos")
    }
    
    private func getGlobalBizPeriod() {
        guard let info = gBizInfo else { return }
        self.currentBizInfo = info.copy()
        self.previousHash = info.hashDataObject()
        
        displayInfo()
    }
    
    private func displayInfo() {
        phoneTextField.text = currentBizInfo.phoneNumber
        emailTextField.text = currentBizInfo.email
        aboutTextView.text = currentBizInfo.about
        policyTextView.text = currentBizInfo.policy
        geoPoint = currentBizInfo.geoPoint
        updateMapCamera()
    }
    
    private func assignData() {
        phone = phoneTextField.text! as String
        email = emailTextField.text! as String
        about = aboutTextView.text! as String
        policy = policyTextView.text! as String
        
        phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        about = about.trimmingCharacters(in: .whitespacesAndNewlines)
        policy = policy.trimmingCharacters(in: .whitespacesAndNewlines)
        
        currentBizInfo.phoneNumber = phone
        currentBizInfo.email = email
        currentBizInfo.about = about
        currentBizInfo.policy = policy
        currentBizInfo.geoPoint = geoPoint
    }
    
    @IBAction func handleGoogleMaps(_ sender: Any?) {
        let controller = PickLocationController()
        controller.previousController = self
        controller.isBizInfo = true
        controller.selectGeoPoint = self.geoPoint
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.barTintColor = UIColor.clear
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleDone(_ sender: Any?) {
        assignData()
        let current = currentBizInfo.hashDataObject()
        if previousHash == current {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            updateBizInfo().then { (check) in
                if check {
                    gBizInfo = self.currentBizInfo
                }
                self.alertController.dismiss(animated: true) {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func updateBizInfo() -> Promise<Bool> {
        alertController = displaySpinner(title: "Updating")
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.bizInfoRef.document(self.currentBizInfo.id).updateData(self.currentBizInfo.toJSON()) { err in
                if let err = err {
                    print("Updated BizInfo is error: \(err)")
                    self.alertController.dismiss(animated: true, completion: nil)
                    resolve(false)
                } else {
                    let updateJson = Mapper().toJSONString(self.currentBizInfo, prettyPrint: true)!
                    print("Updated BizInfo is completed", updateJson)
                    resolve(true)
                }
            }
        }
    }
    
    func updateMapCamera() {
        guard let geoPoint = geoPoint else { return }
        CATransaction.begin()
        CATransaction.setValue(0.5, forKey: kCATransactionAnimationDuration)
        let camera = GMSCameraPosition.camera(withLatitude:  geoPoint.lat, longitude: geoPoint.long, zoom: 18)
        googleMapView.camera = camera
        googleMapView.animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: geoPoint.lat, longitude: geoPoint.long)))
        googleMapView.animate(toZoom: 18)
        googleMapView.isUserInteractionEnabled = false
        CATransaction.commit()
        locationPickerImageView.isHidden = false
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Business Information"
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

    }

}
