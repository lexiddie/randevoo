//
//  PickLocationController.swift
//  randevoo
//
//  Created by Lex on 1/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SnapKit

class PickLocationController: UIViewController, CLLocationManagerDelegate {

    var isBizInfo: Bool = false
    var previousController: UIViewController!
    var selectGeoPoint: GeoPoint? = nil
    
    var locationManager = CLLocationManager()
    var location: CLLocationCoordinate2D!
    var googleMapView: GMSMapView!
    var googlePlacesClient: GMSPlacesClient!
    
    var likelyPlaces: [GMSPlace] = []
    var selectedLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        setupLocationManager()
        updateMapCamera()
    }
    
    private func initialView() {
        let view = PickLocationView(frame: self.view.frame)
        self.googleMapView = view.googleMapView
        self.view = view
        self.hideKeyboardWhenTappedAround()
    }
    
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        googlePlacesClient = GMSPlacesClient.shared()
    }
    
    private func updateMapCamera() {
        guard let geoPoint = selectGeoPoint else { return }
        CATransaction.begin()
        CATransaction.setValue(0.5, forKey: kCATransactionAnimationDuration)
        googleMapView.animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: geoPoint.lat, longitude: geoPoint.long)))
        googleMapView.animate(toZoom: 15)
        googleMapView.isUserInteractionEnabled = true
        CATransaction.commit()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let center = manager.location?.coordinate {
            location = CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude)
            print("Location GPS lat & long: \(String(location.latitude)) & \(String(location.longitude))")
        }
    }
    
    @IBAction func handleApply(_ sender: Any?) {
        let coordinate = googleMapView.projection.coordinate(for: googleMapView.center)
        let currentLocation = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if isBizInfo, let controller = previousController as? BizInfoController {
            let geoPoint = GeoPoint(lat: currentLocation.latitude, long: currentLocation.longitude)
            controller.geoPoint = geoPoint
            controller.updateMapCamera()
        } else if let controller = previousController as? CreateBizInfoController {
            controller.geoPoint = GeoPoint(lat: currentLocation.latitude, long: currentLocation.longitude)
            controller.updateMapCamera()
        }
        print("Get center location lat & long: \(currentLocation)")
        locationManager.stopUpdatingLocation()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        locationManager.stopUpdatingLocation()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func setupNavItems() {
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(named: "DismissIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        dismissButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentHorizontalAlignment = .center
        dismissButton.contentVerticalAlignment = .center
        dismissButton.contentMode = .scaleAspectFit
        dismissButton.backgroundColor = UIColor.white
        dismissButton.layer.cornerRadius = 8
        dismissButton.addTarget(self, action: #selector(handleDismiss(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        dismissButton.snp.makeConstraints{ (make) in
           make.height.width.equalTo(40)
        }
    }
}
