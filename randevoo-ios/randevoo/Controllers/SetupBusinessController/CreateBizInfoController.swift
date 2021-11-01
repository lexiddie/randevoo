//
//  CreateBizInfoController.swift
//  randevoo
//
//  Created by Lex on 23/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import GoogleMaps

class CreateBizInfoController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    var previousController: UIViewController!
    
    private var alertHelper = AlertHelper()
    
    var businessName: String!
    var websiteUrl: String = ""
    var location: String!
    var geoPoint: GeoPoint!
    
    var websiteTextField: UITextField!
    var locationTextField: UITextField!
    var locationPickerImageView: UIImageView!

    var googleMapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
    }
    
    private func initialView() {
        let view = CreateBizInfoView(frame: self.view.frame)
        self.websiteTextField = view.websiteTextField
        self.locationTextField = view.locationTextField
        self.locationPickerImageView = view.locationPickerImageView
        self.googleMapView = view.googleMapView
        self.view = view
        self.websiteTextField.delegate = self
        self.locationTextField.delegate = self
        self.locationPickerImageView.isHidden = true
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func handleLocation(_ sender: Any?) {
        let controller = LocationController()
        controller.previousController = self
        controller.isCreate = true
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.barTintColor = UIColor.randevoo.mainLight
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func handleGoogleMaps(_ sender: Any?) {
        let controller = PickLocationController()
        controller.previousController = self
        controller.selectGeoPoint = self.geoPoint
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.barTintColor = UIColor.clear
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func handleNext(_ sender: Any?) {
        if (locationTextField.text?.isEmpty)! || geoPoint == nil {
            alertHelper.showAlert(title: "Invalid Input", alert: "Your business location & map must not be empty", controller: self)
        } else {
            websiteUrl = websiteTextField.text! as String
            print("Checking WebsiteUrl \(String(websiteUrl))")
            let controller = CreateBizAccountController()
            controller.previousController = previousController
            controller.businessName = businessName
            controller.websiteUrl = websiteUrl
            controller.location = location
            controller.geoPoint = geoPoint
            navigationController?.pushViewController(controller, animated: true)
        }
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
    
    func updateMapCamera() {
        guard let geoPoint = geoPoint else { return }
        CATransaction.begin()
        CATransaction.setValue(0.5, forKey: kCATransactionAnimationDuration)
        googleMapView.animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: geoPoint.lat, longitude: geoPoint.long)))
        googleMapView.animate(toZoom: 15)
        googleMapView.isUserInteractionEnabled = false
        CATransaction.commit()
        locationPickerImageView.isHidden = false
    }
}
