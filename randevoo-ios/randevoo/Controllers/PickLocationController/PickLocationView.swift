//
//  PickLocationView.swift
//  randevoo
//
//  Created by Lex on 23/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import GoogleMaps
import SnapKit

class PickLocationView: UIView {

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
        addSubview(locationPickerImageView)
        locationPickerImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(25)
            make.center.equalTo(googleMapView)
        }
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints{ (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(65)
            make.centerX.equalTo(self)
            make.height.equalTo(25)
        }
        addSubview(applyButton)
        applyButton.snp.makeConstraints{ (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
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

        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        mapView.padding = padding
        mapView.mapType = .normal
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.setMinZoom(7, maxZoom: 20)
        mapView.isUserInteractionEnabled = true
        return mapView
    }()
    
    let locationPickerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LocationPickerIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let infoLabel : UILabel = {
        let label = PaddingLabel()
        label.text = "Drag map to choose location"
        label.textColor = UIColor.white
        label.layer.backgroundColor = UIColor.randevoo.mainBlack.withAlphaComponent(0.5).cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 16)
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.setTitle("Apply", for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.randevoo.mainColor
        button.addTarget(self, action: #selector(PickLocationController.handleApply(_:)), for: .touchUpInside)
        return button
    }()
}
