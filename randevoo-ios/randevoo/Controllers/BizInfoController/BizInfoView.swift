//
//  BizInfoView.swift
//  randevoo
//
//  Created by Lex on 2/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMaps

class BizInfoView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(scrollView)
        scrollView.contentSize = CGSize(width: self.frame.width, height: 780 + 25 + (self.frame.width - 40))
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        scrollView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(scrollView).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(60)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        scrollView.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(detailLabel.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(35)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        scrollView.addSubview(phoneTextField)
        phoneTextField.snp.makeConstraints{ (make) in
            make.top.equalTo(phoneLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        scrollView.addSubview(emailLabel)
        emailLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(phoneTextField.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(35)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        scrollView.addSubview(emailTextField)
        emailTextField.snp.makeConstraints{ (make) in
            make.top.equalTo(emailLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        scrollView.addSubview(aboutLabel)
        aboutLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(emailTextField.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(35)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        scrollView.addSubview(aboutTextView)
        aboutTextView.snp.makeConstraints{ (make) in
            make.top.equalTo(aboutLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(200)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        scrollView.addSubview(policyLabel)
        policyLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(aboutTextView.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(35)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        scrollView.addSubview(policyTextView)
        policyTextView.snp.makeConstraints{ (make) in
            make.top.equalTo(policyLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(200)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        scrollView.addSubview(googleLabel)
        googleLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(policyTextView.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(35)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        scrollView.addSubview(googleMapView)
        googleMapView.snp.makeConstraints { (make) in
            make.top.equalTo(googleLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(self.frame.width - 40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        scrollView.addSubview(locationPickerImageView)
        locationPickerImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(25)
            make.center.equalTo(googleMapView)
        }
        scrollView.addSubview(googleMapButton)
        googleMapButton.snp.makeConstraints { (make) in
            make.top.equalTo(googleLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(self.frame.width - 40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
    }

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    let detailLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "This information will be displayed on your profile publicly so people can contact you. \nYou can edit or remove this information at any time"
        label.font = UIFont(name: "Quicksand-Medium", size: 16)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 3
        return label
    }()
    
    let phoneLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "Phone"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let phoneTextField: UITextField = {
        let textField = UITextField(placeholder: "Phone number", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .phonePad, autoCorrectionType: .no, autoCapitalizationType: .none)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.randevoo.mainColor
        textField.font = UIFont(name: "Quicksand-Medium", size: 16)
        textField.isEnabled = true
        return textField
    }()
    
    let emailLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "Email"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField(placeholder: "Email", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .emailAddress, autoCorrectionType: .no, autoCapitalizationType: .none)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.randevoo.mainColor
        textField.font = UIFont(name: "Quicksand-Medium", size: 16)
        textField.isEnabled = true
        return textField
    }()
    
    let aboutLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "About"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let aboutTextView: UITextView = {
        let textView = UITextView()
//        textView.textColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.8)
        textView.textColor = UIColor.white
        textView.text = "A little description about your business"
        textView.font = UIFont(name: "Quicksand-Medium", size: 16)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.randevoo.mainColor.cgColor
        textView.backgroundColor = UIColor.randevoo.mainColor
        textView.isScrollEnabled = true
        return textView
    }()
    
    let policyLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "Policy"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let policyTextView: UITextView = {
        let textView = UITextView()
//        textView.textColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.8)
        textView.textColor = UIColor.white
        textView.text = "Describe your business policy"
        textView.font = UIFont(name: "Quicksand-Medium", size: 16)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.randevoo.mainColor.cgColor
        textView.backgroundColor = UIColor.randevoo.mainColor
        textView.isScrollEnabled = true
        return textView
    }()
    
    let googleLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "Google Maps"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let googleMapView: GMSMapView = {
        var defaults = UserDefaults.standard
        var location: CLLocationCoordinate2D!
        var greyModeStyle: GMSMapStyle!
        let updateLocation = defaults.object(forKey: "location")
        if let number = updateLocation as? [String: Double] {
            let latitude = number["latitude"]
            let longitude = number["longitude"]
            if latitude != nil && longitude != nil {
                location = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            }
        } else {
            location = CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018)
        }
        let camera = GMSCameraPosition.camera(withTarget: location, zoom: 18)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)

        if let file = Bundle.main.url(forResource: "GoogleMaps", withExtension: "json") {
            greyModeStyle = try! GMSMapStyle.init(contentsOfFileURL: file)
            mapView.mapStyle = greyModeStyle
        }

        mapView.layer.cornerRadius = 5
        mapView.mapType = .normal
        mapView.isUserInteractionEnabled = false
        mapView.setMinZoom(7, maxZoom: 20)
        return mapView
    }()
    
    let locationPickerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LocationPickerIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let googleMapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(BizInfoController.handleGoogleMaps(_:)), for: .touchUpInside)
        return button
    }()
}
