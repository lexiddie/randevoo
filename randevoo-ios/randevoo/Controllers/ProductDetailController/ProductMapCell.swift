//
//  ProductMapCell.swift
//  randevoo
//
//  Created by Lex on 3/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMaps

class ProductMapCell: UICollectionViewCell {
    
    var storeInfo: BizInfo? {
        didSet {
            guard let storeInfo = storeInfo else { return }
            
            if storeInfo.geoPoint.lat != 0.0 && storeInfo.geoPoint.long != 0.0 {
                updateMapCamera(geoPoint: storeInfo.geoPoint)
            }
        }
    }
    
    func updateMapCamera(geoPoint: GeoPoint) {
        CATransaction.begin()
        CATransaction.setValue(0.5, forKey: kCATransactionAnimationDuration)
        let camera = GMSCameraPosition.camera(withLatitude:  geoPoint.lat, longitude: geoPoint.long, zoom: 15)
        googleMapView.camera = camera
//        googleMapView.animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: geoPoint.lat, longitude: geoPoint.long)))
//        googleMapView.animate(toZoom: 15)
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
    
    private func setupUI(){
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.height.equalTo(35)
            make.centerX.equalTo(self)
        }
        addSubview(googleMapView)
        googleMapView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.bottom.equalTo(self).inset(30)
        }
        addSubview(storeLocationImageView)
        storeLocationImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(45)
            make.center.equalTo(googleMapView)
        }
    }
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
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
