//
//  CreateBizInfoView.swift
//  randevoo
//
//  Created by Lex on 30/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMaps

class CreateBizInfoView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(websiteNameLabel)
        websiteNameLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(50)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(websiteOptionalLabel)
        websiteOptionalLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(50)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(websiteTextField)
        websiteTextField.snp.makeConstraints{ (make) in
            make.top.equalTo(websiteNameLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(selectLocationLabel)
        selectLocationLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(websiteTextField.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(locationTextField)
        locationTextField.snp.makeConstraints{ (make) in
            make.top.equalTo(selectLocationLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(locationButton)
        locationButton.snp.makeConstraints{ (make) in
            make.top.equalTo(selectLocationLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(googleMapLabel)
        googleMapLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(locationTextField.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(googleMapView)
        googleMapView.snp.makeConstraints { (make) in
            make.top.equalTo(googleMapLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(50)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(locationPickerImageView)
        locationPickerImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(25)
            make.center.equalTo(googleMapView)
        }
        addSubview(googleMapButton)
        googleMapButton.snp.makeConstraints { (make) in
            make.top.equalTo(googleMapLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(50)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(nextButton)
        nextButton.snp.makeConstraints{ (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
    }
    
    let websiteNameLabel: UILabel = {
        let label = UILabel()
        label.text = "What is your website?"
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let websiteOptionalLabel: UILabel = {
        let label = UILabel()
        label.text = "Optional"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.textAlignment = .right
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    let websiteTextField: UITextField = {
        let textField = UITextField(placeholder: "Website name", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .default, autoCorrectionType: .no, autoCapitalizationType: .none)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.randevoo.mainColor
        textField.isEnabled = true
        return textField
    }()
    
    let selectLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "Select your location"
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let locationTextField: UITextField = {
        let textField = UITextField(placeholder: "Select location", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .default, autoCorrectionType: .yes, autoCapitalizationType: .words)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.randevoo.mainColor
        textField.isEnabled = false
        return textField
    }()
    
    let locationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(CreateBizInfoController.handleLocation(_:)), for: .touchUpInside)
        return button
    }()

    let googleMapLabel: UILabel = {
        let label = UILabel()
        label.text = "Setup Google Maps"
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
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
        let camera = GMSCameraPosition.camera(withTarget: location, zoom: 15)
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
        button.addTarget(self, action: #selector(CreateBizInfoController.handleGoogleMaps(_:)), for: .touchUpInside)
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 16)
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.setTitle("Next", for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.randevoo.mainColor
        button.addTarget(self, action: #selector(CreateBizInfoController.handleNext(_:)), for: .touchUpInside)
        return button
    }()

}
