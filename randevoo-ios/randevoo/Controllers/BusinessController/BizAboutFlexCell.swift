//
//  BizAboutFlexCell.swift
//  randevoo
//
//  Created by Alexander on 14/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMaps

class BizAboutFlexCell: UICollectionViewCell {
    
    private let timestampHelper = TimestampHelper()
    
    var info: BizInfo? {
        didSet {
            guard let info = info else { return }
            joinedDateLabel.text = "Joined in \(String(timestampHelper.toJoinedDate(date: info.createdAt.iso8601withFractionalSeconds!)))"
            locationTextField.text = "Google Maps"
            
            if info.phoneNumber != "" {
                phoneTextField.text = info.phoneNumber
            } else {
                phoneTextField.text = "No telephone to show"
            }
            
            if info.email != "" {
                emailTextField.text = info.email
            } else {
                emailTextField.text = "No email to show"
            }
            
            if info.about != "" {
                aboutTextView.text = info.about
            } else {
                aboutTextView.text = "No about to show"
            }
            
            if info.policy != "" {
                policyTextView.text = info.policy
            } else {
                policyTextView.text = "No policy to show"
            }
            
            if info.geoPoint.lat != 0.0 && info.geoPoint.long != 0.0 {
                updateMapCamera(geoPoint: info.geoPoint)
            }
        }
    }
    
    func updateMapCamera(geoPoint: GeoPoint) {
        CATransaction.begin()
        CATransaction.setValue(0.5, forKey: kCATransactionAnimationDuration)
        googleMapView.animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: geoPoint.lat, longitude: geoPoint.long)))
        googleMapView.animate(toZoom: 15)
        googleMapView.isUserInteractionEnabled = false
        CATransaction.commit()
        storeLocationImageView.isHidden = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(joinedDateLabel)
        joinedDateLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(self).inset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(joinedLineView)
        joinedLineView.snp.makeConstraints { (make) in
            make.top.equalTo(joinedDateLabel.snp.bottom).offset(20)
            make.height.equalTo(0.5)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(contactLabel)
        contactLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(joinedLineView.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(phoneStackView)
        phoneStackView.addArrangedSubview(phoneImageView)
        phoneStackView.addArrangedSubview(phoneTextField)
        phoneStackView.snp.makeConstraints { (make) in
            make.top.equalTo(contactLabel.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        phoneImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(phoneStackView)
            make.height.width.equalTo(30)
        }
        phoneTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(phoneStackView)
            make.height.equalTo(40)
            make.width.equalTo(self.frame.width - 80)
        }
        addSubview(phoneButton)
        phoneButton.snp.makeConstraints { (make) in
            make.top.equalTo(contactLabel.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        addSubview(emailStackView)
        emailStackView.addArrangedSubview(emailImageView)
        emailStackView.addArrangedSubview(emailTextField)
        emailStackView.snp.makeConstraints { (make) in
            make.top.equalTo(phoneStackView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        emailImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(emailStackView)
            make.height.width.equalTo(30)
        }
        emailTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(emailStackView)
            make.height.equalTo(40)
            make.width.equalTo(self.frame.width - 80)
        }
        addSubview(emailButton)
        emailButton.snp.makeConstraints { (make) in
            make.top.equalTo(phoneStackView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        addSubview(contactLineView)
        contactLineView.snp.makeConstraints { (make) in
            make.top.equalTo(emailStackView.snp.bottom).offset(20)
            make.height.equalTo(0.5)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(aboutLabel)
        aboutLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(contactLineView.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(aboutTextView)
        aboutTextView.snp.makeConstraints { (make) in
            make.top.equalTo(aboutLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(200)
            make.left.right.lessThanOrEqualTo(15)
        }
        addSubview(aboutLineView)
        aboutLineView.snp.makeConstraints { (make) in
            make.top.equalTo(aboutTextView.snp.bottom).offset(20)
            make.height.equalTo(0.5)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(policyLabel)
        policyLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(aboutLineView.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(policyTextView)
        policyTextView.snp.makeConstraints { (make) in
            make.top.equalTo(policyLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(100)
            make.left.right.lessThanOrEqualTo(15)
        }
        addSubview(policyLineView)
        policyLineView.snp.makeConstraints { (make) in
            make.top.equalTo(policyTextView.snp.bottom).offset(20)
            make.height.equalTo(0.5)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(locationLabel)
        locationLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(policyLineView.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(locationStackView)
        locationStackView.addArrangedSubview(locationImageView)
        locationStackView.addArrangedSubview(locationTextField)
        locationStackView.snp.makeConstraints { (make) in
            make.top.equalTo(locationLabel.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        locationImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(locationStackView)
            make.height.width.equalTo(30)
        }
        locationTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(locationStackView)
            make.height.equalTo(40)
            make.width.equalTo(self.frame.width - 80)
        }
        addSubview(googleMapView)
        googleMapView.snp.makeConstraints { (make) in
            make.top.equalTo(locationTextField.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.width.equalTo(self.frame.width - 30)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(googleMapButton)
        googleMapButton.snp.makeConstraints { (make) in
            make.top.equalTo(locationTextField.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.width.equalTo(self.frame.width - 30)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(storeLocationImageView)
        storeLocationImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(45)
            make.center.equalTo(googleMapView)
        }
    }
    
    let joinedDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let joinedLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
    
    let contactLabel: UILabel = {
        let label = UILabel()
        label.text = "Contact Info"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    let phoneStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.axis = .horizontal
        stackView.alignment = .leading
        return stackView
    }()
    
    let phoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "TelephoneIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Quicksand-Medium", size: 17)
        textField.textColor = UIColor.randevoo.mainBlack
        textField.textAlignment = .left
        textField.backgroundColor = UIColor.clear
        textField.autocorrectionType = .no
        textField.borderStyle = UITextField.BorderStyle.none
        textField.isEnabled = false
        textField.attributedPlaceholder = NSAttributedString(string: "Phone", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        return textField
    }()
    
    let phoneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(BusinessController.handlePhone(_:)), for: .touchUpInside)
        return button
    }()
    
    let emailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.axis = .horizontal
        stackView.alignment = .leading
        return stackView
    }()
    
    let emailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmailIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Quicksand-Medium", size: 17)
        textField.textColor = UIColor.randevoo.mainBlack
        textField.textAlignment = .left
        textField.backgroundColor = UIColor.clear
        textField.autocorrectionType = .no
        textField.borderStyle = UITextField.BorderStyle.none
        textField.isEnabled = false
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        return textField
    }()
    
    let emailButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(BusinessController.handleEmail(_:)), for: .touchUpInside)
        return button
    }()
    
    let contactLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
    
    let aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "About"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let aboutTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.randevoo.mainBlack.withAlphaComponent(0.8)
        textView.text = "About"
        textView.font = UIFont(name: "Quicksand-Medium", size: 16)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.clear.cgColor
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    
    let aboutLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
    
    let policyLabel: UILabel = {
        let label = UILabel()
        label.text = "Policy"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let policyTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.randevoo.mainBlack.withAlphaComponent(0.8)
        textView.text = "Policy"
        textView.font = UIFont(name: "Quicksand-Medium", size: 16)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.clear.cgColor
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    
    let policyLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let locationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.axis = .horizontal
        stackView.alignment = .leading
        return stackView
    }()
    
    let locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "GoogleMapsIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let locationTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Quicksand-Medium", size: 17)
        textField.textColor = UIColor.randevoo.mainBlack
        textField.textAlignment = .left
        textField.backgroundColor = UIColor.clear
        textField.autocorrectionType = .no
        textField.borderStyle = UITextField.BorderStyle.none
        textField.isEnabled = false
        textField.attributedPlaceholder = NSAttributedString(string: "Location", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        return textField
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
    
    let googleMapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(BusinessController.handleGoogleMaps(_:)), for: .touchUpInside)
        return button
    }()
    
    let storeLocationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "StoreLocationIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 45/2
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.backgroundColor = UIColor.white
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
}
