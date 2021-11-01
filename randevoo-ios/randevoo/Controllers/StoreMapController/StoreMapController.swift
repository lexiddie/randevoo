//
//  StoreMapController.swift
//  randevoo
//
//  Created by Xell on 19/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON
import FirebaseAuth
import FirebaseFirestore
import Hydra
import Presentr
import GoogleMaps
import GooglePlaces
import Alamofire

class StoreMapController: UIViewController, CLLocationManagerDelegate {
    
    var storeAccount: StoreAccount!
    var storeInfo: BizInfo!
    
    private var alertHelper = AlertHelper()
    private let db = Firestore.firestore()
    private var businessRef: CollectionReference!
    private var bizInfoRef: CollectionReference!
    private var bizPeriodRef: CollectionReference!
    
    private var width: CGFloat = UIScreen.main.bounds.width
    private var locationManager = CLLocationManager()
    private var location: CLLocationCoordinate2D!
    private var googleMapView: GMSMapView!
    private var storeImageView: UIImageView!
    private var usernameLabel: UILabel!
    private var locationLabel: UILabel!
    private var distanceLabel: UILabel!
    
    private var distanceString: String = ""
    private var isToClear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initiateFirestore()
        setupLocationManager()
        startLocatedStore()
    }
    
    func initialView() {
        let view = StoreMapView(frame: self.view.frame)
        self.googleMapView = view.googleMapView
        self.storeImageView = view.storeImageView
        self.usernameLabel = view.usernameLabel
        self.locationLabel = view.locationLabel
        self.distanceLabel = view.distanceLabel
        self.view = view
        self.hideKeyboardWhenTappedAround()
    }
    
    private func initiateInfo() {
        guard let store = storeAccount else { return }
        if store.profileUrl != "" {
            storeImageView.loadCacheProfile(urlString: store.profileUrl)
        } else {
            storeImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        }
        usernameLabel.text = store.username
        locationLabel.text = store.location
        distanceLabel.text = distanceString
    }
    
    private func initiateFirestore() {
        businessRef = db.collection("businesses")
        bizInfoRef = db.collection("bizInfos")
        bizPeriodRef = db.collection("bizPeriods")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func updateMapCamera() {
        guard let geoPoint = storeInfo.geoPoint else { return }
        CATransaction.begin()
        CATransaction.setValue(0.5, forKey: kCATransactionAnimationDuration)
        googleMapView.animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: geoPoint.lat, longitude: geoPoint.long)))
        googleMapView.animate(toZoom: 15)
        googleMapView.isUserInteractionEnabled = true
        CATransaction.commit()
    }
    
    private func setupLocationManager() {
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
    
    func markStore(storeInfo: BizInfo) {
        googleMapView.clear()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: (width / 5), height: (width / 5)))
        imageView.image = UIImage(named: "StoreLocationIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = (width / 5) * 0.5
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.randevoo.mainLightGrey.cgColor
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: storeInfo.geoPoint.lat, longitude: storeInfo.geoPoint.long)
        marker.title = storeAccount.username
        marker.snippet = "\(String(storeAccount.location)) \n\(distanceString)"
        marker.iconView = imageView
        marker.tracksViewChanges = true
        marker.map = googleMapView
    }
    
    private func findDistance() -> String {
        guard let location = location else { return "Your location is not enable!🥺" }
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let storeCoordinate = CLLocation(latitude: storeInfo.geoPoint.lat, longitude: storeInfo.geoPoint.long)
        let distanceInKilo = userLocation.distance(from: storeCoordinate) / 1000
        return "You are \(String(format:"%.02f", distanceInKilo)) km away from store"
    }
    
    func startLocatedStore() {
        fetchStoreInfo().then { (check) in
            if check {
                self.updateMapCamera()
                self.distanceString = self.findDistance()
                self.markStore(storeInfo: self.storeInfo)
                self.initiateInfo()
            }
        }
        print("Fetch New Store Info")
    }
    
    private func fetchStoreInfo() -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let store = self.storeAccount else {
                resolve(false)
                return
            }
            self.bizInfoRef
                .whereField("businessId", isEqualTo: (store.id)!)
                .limit(to: 1)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        resolve(false)
                    } else {
                        for document in querySnapshot!.documents {
                            let record = Mapper<BizInfo>().map(JSONObject: document.data())!
                            self.storeInfo = record
                            resolve(true)
                        }
                    }
                }
        }
    }
    
    @IBAction func handleStoreMap(_ sender: Any?) {
        updateMapCamera()
    }
    
    @IBAction func handleDirection(_ sender: Any?) {
        if isToClear {
            googleMapView.clear()
            updateMapCamera()
            markStore(storeInfo: storeInfo)
            isToClear = false
        } else {
            guard let location = location else {
                alertHelper.showAlert(title: "Notice", alert: "Your location is not enable!🥺", controller: self)
                return
            }
            let sourceLocation = "\(location.latitude),\(location.longitude)"
            let destinationLocation = "\(String((storeInfo?.geoPoint.lat!)!)),\(String((storeInfo?.geoPoint.long!)!))"
            let googleMapsApiKey = "replace-your-api-key"
            // MARK: Create URL
            let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceLocation)&destination=\(destinationLocation)&mode=driving&key=\(googleMapsApiKey)"
            AF.request(url).responseJSON { (response) in
                guard let data = response.data else {
                    return
                }
                do {
                    let jsonData = try JSON(data: data)
                    let routes = jsonData["routes"].arrayValue
                    for route in routes {
                        let overviewPolyLine = route["overview_polyline"].dictionary
                        let points = overviewPolyLine?["points"]?.string
                        let path = GMSPath.init(fromEncodedPath: points ?? "")
                        let polyLine = GMSPolyline.init(path: path)
                        polyLine.strokeColor = UIColor.randevoo.mainColor
                        polyLine.strokeWidth = 5
                        polyLine.map = self.googleMapView
                    }
                }
                catch let error {
                    print(error.localizedDescription)
                }
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: (35), height: (35)))
                imageView.image = UIImage(named: "LocationPickerIcon")!.withRenderingMode(.alwaysOriginal)
                imageView.layer.cornerRadius = 35 / 2
                imageView.layer.borderWidth = 1
                imageView.layer.borderColor = UIColor.randevoo.mainLightGrey.cgColor
                imageView.backgroundColor = UIColor.white
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                let sourceMarker = GMSMarker()
                sourceMarker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                sourceMarker.title = "You"
                sourceMarker.iconView = imageView
                sourceMarker.map = self.googleMapView
                let camera = GMSCameraPosition(target: sourceMarker.position, zoom: 10)
                self.googleMapView.animate(to: camera)
                self.isToClear = true
            }
        }
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        locationManager.stopUpdatingLocation()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleGoogle(_ sender: Any?) {
        guard let info = storeInfo else { return }
        guard let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(String(info.geoPoint.lat)),\(String(info.geoPoint.long))") else { return }
        UIApplication.shared.open(url)
    }
    
    private func setupNavItems() {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "ArrowLeft")!.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentHorizontalAlignment = .center
        backButton.contentVerticalAlignment = .center
        backButton.contentMode = .scaleAspectFit
        backButton.backgroundColor = UIColor.white
        backButton.layer.cornerRadius = 8
        backButton.addTarget(self, action: #selector(handleBack(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.snp.makeConstraints{ (make) in
            make.height.width.equalTo(40)
        }
        
        let googleButton = UIButton(type: .system)
        googleButton.setImage(UIImage(named: "GoogleMapsIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        googleButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        googleButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        googleButton.contentHorizontalAlignment = .center
        googleButton.contentVerticalAlignment = .center
        googleButton.contentMode = .scaleAspectFit
        googleButton.backgroundColor = UIColor.white
        googleButton.layer.cornerRadius = 8
        googleButton.addTarget(self, action: #selector(handleGoogle(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: googleButton)
        googleButton.snp.makeConstraints{ (make) in
            make.height.width.equalTo(40)
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}
