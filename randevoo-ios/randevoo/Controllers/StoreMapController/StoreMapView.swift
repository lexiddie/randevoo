//
//  StoreMapView.swift
//  randevoo
//
//  Created by Lex on 14/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMaps
import Alamofire
import AlamofireImage
import Hydra

class StoreMapView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(googleMapView)
        googleMapView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        googleMapView.addSubview(storeInfoView)
        storeInfoView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(80)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(100)
        }
        googleMapView.addSubview(storeInfoButton)
        storeInfoButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(80)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(100)
        }
        storeInfoView.addSubview(storeStackView)
        storeStackView.addArrangedSubview(storeView)
        storeStackView.addArrangedSubview(infoStackView)
        storeStackView.snp.makeConstraints { (make) in
            make.centerX.equalTo(storeInfoView)
            make.height.equalTo(100)
            make.left.right.lessThanOrEqualTo(storeInfoView)
        }
        storeView.snp.makeConstraints { (make) in
            make.centerY.equalTo(storeStackView)
            make.height.width.equalTo(80)
        }
        storeView.addSubview(storeImageView)
        storeImageView.snp.makeConstraints { (make) in
            make.center.equalTo(storeView)
            make.height.width.equalTo(60)
        }
        infoStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(storeStackView)
            make.height.equalTo(100)
            make.width.equalTo(self.frame.width - 120)
            make.right.equalTo(storeStackView)
        }
        infoStackView.addArrangedSubview(usernameLabel)
        infoStackView.addArrangedSubview(locationLabel)
        infoStackView.addArrangedSubview(distanceLabel)
        googleMapView.addSubview(directionButton)
        directionButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).inset(45)
            make.right.lessThanOrEqualTo(self).inset(80)
            make.height.width.equalTo(57)
        }
    }
    
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

        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        mapView.padding = padding
        mapView.mapType = .normal
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.setMinZoom(7, maxZoom: 20)
        mapView.layer.cornerRadius = 0
        mapView.isUserInteractionEnabled = true
        return mapView
    }()
    
    let storeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.alignment = .leading
        return stackView
    }()
    
    let storeInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainLight
        view.layer.cornerRadius = 20
        return view
    }()
    
    let storeInfoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(StoreMapController.handleStoreMap(_:)), for: .touchUpInside)
        return button
    }()
    
    let storeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let storeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 60/2
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.randevoo.mainWhiteGray.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainWhiteGray
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let usernameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(20, 5, 0, 5)
        return label
    }()
    
    let locationLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 16)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let distanceLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 16)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 20, 5)
        return label
    }()
    
    let directionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "DirectionIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.randevoo.mainColor
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.randevoo.mainWhiteGray.cgColor
        button.layer.cornerRadius = 57 / 2
        button.addTarget(self, action: #selector(StoreMapController.handleDirection(_:)), for: .touchUpInside)
        return button
    }()
    

}
