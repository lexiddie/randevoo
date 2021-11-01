//
//  SearchMapView.swift
//  randevoo
//
//  Created by Lex on 27/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMaps
import Alamofire
import AlamofireImage
import Hydra

protocol SearchMapViewDelegate {
    func didSelectOnMap(indexProduct: Int)
}

class SearchMapView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate, GMSMapViewDelegate  {

    var delegate: SearchMapViewDelegate?
    var width: CGFloat = UIScreen.main.bounds.width
    var products: [ListProduct] = []
    
    private var selectedIndex: Int = 0
    private let productFlexCell = "productFlexCell"
    private let numberFormatter = NumberFormatter()
    
    var locationManager = CLLocationManager()
    var location: CLLocationCoordinate2D!
    
    private var distanceString: String = ""
    
    func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let center = manager.location?.coordinate {
            location = CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude)
            print("Location GPS lat & long: \(String(location.latitude)) & \(String(location.longitude))")
        }
    }
    
    
    func updateMapCamera(geoPoint: GeoPoint) {
        CATransaction.begin()
        CATransaction.setValue(0.5, forKey: kCATransactionAnimationDuration)
        googleMapView.animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: geoPoint.lat, longitude: geoPoint.long)))
        googleMapView.animate(toZoom: 15)
        CATransaction.commit()
    }
    
    func loadFriendlyLabel() {
        if products.count == 0 {
            friendlyLabel.text = "No products to show😴"
        } else {
            friendlyLabel.text = nil
        }
    }
    
    func markProduct(product: ListProduct) {
        distanceString = findDistance(product: product)
        numberFormatter.numberStyle = .decimal
        googleMapView.clear()
        updateMapCamera(geoPoint: product.bizGeoPoint)
        let priceFormat = numberFormatter.string(from: NSNumber(value: product.price))
        guard let geoPoint = product.bizGeoPoint else { return }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: (width / 3), height: (width / 3)))
        imageView.loadCacheImage(urlString: product.photoUrl)
        imageView.layer.cornerRadius = (width / 3) * 0.5
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.randevoo.mainWhiteGray.cgColor
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: geoPoint.lat, longitude: geoPoint.long)
        marker.title = product.name
        marker.snippet = "฿\(String(priceFormat!)) \n\(distanceString)"
        marker.iconView = imageView
        marker.tracksViewChanges = true
        marker.map = googleMapView
    }
    
    private func findDistance(product: ListProduct) -> String {
        guard let location = location else { return "Your location is not enable! 🥺" }
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let productCoordinate = CLLocation(latitude: product.bizGeoPoint.lat, longitude: product.bizGeoPoint.long)
        let distanceInKilo = userLocation.distance(from: productCoordinate) / 1000
        return "You are \(String(format:"%.02f", distanceInKilo)) km away from store"
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("Tap marker")
        delegate?.didSelectOnMap(indexProduct: selectedIndex)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        initiateCollectionView()
        initiateGoogleMap()
        setupLocationManager()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        self.isHidden = true
        addSubview(productCollectionView)
        productCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.height.equalTo((width / 4) + 20)
            make.left.right.lessThanOrEqualTo(self)
            make.centerX.equalTo(self)
        }
        addSubview(friendlyLabel)
        friendlyLabel.snp.makeConstraints{ (make) in
            make.left.right.equalTo(productCollectionView).inset(30)
            make.center.equalTo(productCollectionView)
        }
        addSubview(googleMapView)
        googleMapView.snp.makeConstraints { (make) in
            make.top.equalTo(productCollectionView.snp.bottom)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.bottom.equalTo(self)
        }
    }
    
    private func initiateCollectionView() {
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        productCollectionView.register(ProductFlexCell.self, forCellWithReuseIdentifier: productFlexCell)
        productCollectionView.keyboardDismissMode = .onDrag
    }
    
    private func initiateGoogleMap() {
        googleMapView.delegate = self
    }

    lazy var productCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.layer.cornerRadius = 10
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = true
        return collectionView
    }()
    
    let friendlyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
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
}


extension SearchMapView {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (width) / 4
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productFlexCell, for: indexPath) as! ProductFlexCell
        cell.product = products[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        markProduct(product: products[indexPath.item])
        selectedIndex = indexPath.item
    }
}
