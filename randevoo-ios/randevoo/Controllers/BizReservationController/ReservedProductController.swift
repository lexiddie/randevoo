//
//  ReservedProductController.swift
//  randevoo
//
//  Created by Lex on 6/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import ObjectMapper
import SwiftyJSON
import Alamofire
import AlamofireImage
import Cache
import SnapKit
import Hydra

class ReservedProductController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var isFromBizReservation: Bool = false
    var bizReservation: BizReservation!
    var reservation: Reservation!
    var user: User!
    
    var updateProductController: UpdateProductController!
    var updateNavController: UINavigationController!
        
    private let alertHelper = AlertHelper()
    private let db = Firestore.firestore()
    private var reservationRef: CollectionReference!
    private var productRef: CollectionReference!
    private var userRef: CollectionReference!
    private var businessRef: CollectionReference!
    private var timeslotRef: CollectionReference!
    private var bizPeriodRef: CollectionReference!
    private var alertController: UIAlertController!
    
    private let reservedSlideCell = "reservedSlideCell"
    private let reservedInfoCell = "reservedInfoCell"
    private let reservedProductCell = "reservedProductCell"
    private var cachedTimeslots: [Timeslot] = []
    private var cachedProducts: [Product] = []
    private var products: [Product] = []
    private var slidePhotos: [String] = []
    private var timeslots: [Timeslot] = []
 
    private var reservedCollectionView: UICollectionView!
    private var headerSlide: ReservedSlideCell?
    private var floatingSlide = ReservedSlideCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialCollectionView()
        initiateFirestore()
        fetchSelection()
        loadController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private func initialView() {
        let view = ReservedProductView(frame: self.view.frame)
        self.reservedCollectionView = view.reservedCollectionView
        self.view = view
    }
    
    private func initialCollectionView() {
        reservedCollectionView.delegate = self
        reservedCollectionView.dataSource = self
        reservedCollectionView.register(ReservedSlideCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reservedSlideCell)
        reservedCollectionView.register(ReservedInfoCell.self, forCellWithReuseIdentifier: reservedInfoCell)
        reservedCollectionView.register(ReservedProductCell.self, forCellWithReuseIdentifier: reservedProductCell)
    }
    
    private func initiateFirestore() {
        reservationRef = db.collection("reservations")
        productRef = db.collection("products")
        userRef = db.collection("users")
        businessRef = db.collection("businesses")
        timeslotRef = db.collection("timeslots")
        bizPeriodRef = db.collection("bizPeriods")
    }
    
    func setCachedProducts(records: [Product]) {
        self.cachedProducts = records
    }
    
    func loadController() {
        updateProductController = UpdateProductController()
        updateNavController = UINavigationController(rootViewController: updateProductController)
        updateNavController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        updateNavController.navigationBar.shadowImage = UIImage()
        updateNavController.navigationBar.isTranslucent = false
        updateNavController.navigationBar.barTintColor = UIColor.randevoo.mainLight
    }
    
    func dispatchUpdateProduct() {
        updateProductController.previousController = self
        updateProductController.cachedProducts = cachedProducts
        updateProductController.reservedProducts = products
        updateProductController.loadUpdate()
        self.navigationController?.present(updateNavController, animated: true, completion: nil)
    }
    
    private func fetchSelection() {
        fetchBizPeriod()
        if isFromBizReservation {
            guard let bizReservation = bizReservation else { return }
            self.user = bizReservation.user
            let productIds = getProductIds(bizReservation: bizReservation)
            fetchCachedProducts(productIds: productIds).then { (cachedProducts) in
                self.cachedProducts = cachedProducts
                self.getSlidePhotos()
                self.getProducts()
            }
            fetchTimeslots().then { (results) in
                self.timeslots = results
            }
        } else {
            guard let reservation = reservation else { return }
            let _ = async { (_) -> (User, Timeslot) in
                let user = try await(self.fetchUser(userId: reservation.userId))
                let timeslot = try await(self.fetchTimeslot(timeslotId: reservation.timeslotId))
                return (user, timeslot)
            }.then { (user, timeslot) in
                self.user = user
                self.bizReservation = BizReservation(reservation: reservation, user: user, timeslot: timeslot)
                let productIds = self.getProductIds(bizReservation: self.bizReservation)
                self.fetchCachedProducts(productIds: productIds).then { (cachedProducts) in
                    self.cachedProducts = cachedProducts
                    self.getSlidePhotos()
                    self.getProducts()
                }
                self.fetchTimeslots().then { (results) in
                    self.timeslots = results
                }
            }
            
        }
    }
    
    private func fetchUser(userId: String) -> Promise<User> {
        return Promise<User>(in: .background) { (resolve, reject, _) in
            self.userRef.document(userId).getDocument { (document, error) in
                if let document = document, document.exists {
                    let result = Mapper<User>().map(JSONObject: document.data())!
                    resolve(result)
                } else {
                    print("Document does not exist")
                    reject(error!)
                }
            }
        }
    }
    
    private func fetchTimeslot(timeslotId: String) -> Promise<Timeslot> {
        return Promise<Timeslot>(in: .background) { (resolve, reject, _) in
            self.timeslotRef.document(timeslotId).getDocument { (document, error) in
                if let document = document, document.exists {
                    let result = Mapper<Timeslot>().map(JSONObject: document.data())!
                    resolve(result)
                } else {
                    print("Document does not exist")
                    reject(error!)
                }
            }
        }
    }
    
    private func fetchBizPeriod() {
        guard let business = businessAccount else { return }
        bizPeriodRef
            .whereField("businessId", isEqualTo: (business.id)!)
            .limit(to: 1)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let record = Mapper<BizPeriod>().map(JSONObject: document.data())!
                        gBizPeriod = record
                    }
                }
            }
    }
    
    private func fetchTimeslots() -> Promise<[Timeslot]> {
        return Promise<[Timeslot]>(in: .background) { (resolve, reject, _) in
            guard let business = businessAccount else {
                resolve([])
                return
            }
            guard let reservation = self.bizReservation else {
                resolve([])
                return
            }
            // Handle check specific timeslot later when store owner change business hours
            self.timeslotRef
                .whereField("businessId", isEqualTo: business.id as Any)
                .whereField("date", isEqualTo: (reservation.timeslot.date)!)
                .whereField("time", isEqualTo: (reservation.timeslot.time)!)
                .whereField("isApproved", isEqualTo: true)
                .limit(to: 10)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        reject(err)
                    } else {
                        var tempList: [Timeslot] = []
                        for document in querySnapshot!.documents {
                            let timeslot = Mapper<Timeslot>().map(JSONObject: document.data())!
                            tempList.append(timeslot)
                        }
                        resolve(tempList)
                    }
                }
        }
    }
    
    private func verifyTimeslots() -> Bool {
        guard let period = gBizPeriod else { return false }
        if timeslots.count < Int(period.bizAvailability.value) {
            return true
        }
        return false
    }
    
    private func verifyProducts() -> Bool {
        guard let bizReservation = bizReservation else { return false }
        var count = 0
        for i in bizReservation.products {
            if let product = cachedProducts.first(where: {$0.id == i.productId}) {
                if let variants = product.variants.first(where: {$0.color == i.variant.color && $0.size == i.variant.size }) {
                    if variants.available >= i.variant.quantity {
                        count += 1
                    }
                }
            }
            if count == bizReservation.products.count {
                return true
            }
        }
        return false
    }
    
    func verifyReservation() -> Bool {
        let validateTimeslot = verifyTimeslots()
        let validateProduct = verifyProducts()
        return validateTimeslot && validateProduct
    }
    
    private func getProducts() {
        guard let bizReservation = bizReservation else { return }
//        let resultJson = Mapper().toJSONString(bizReservation, prettyPrint: true)!
//        print("\nBizReservation: \(resultJson)")
        var tempList: [Product] = []
        for i in bizReservation.products {
            if let product = cachedProducts.first(where: {$0.id == i.productId}) {
                if let variant = product.variants.first(where: {$0.color == i.variant.color && $0.size == i.variant.size }) {
                    let current = product.copy()
                    current.variants.removeAll()
                    current.variants.append(variant.copy())
//                    let variantJson = Mapper().toJSONString(variant, prettyPrint: true)!
//                    print("\nVariant: \(variantJson)")
                    current.variants[0].quantity = i.variant.quantity
                    tempList.append(current)
                }
            }
        }
//        let result1Json = Mapper().toJSONString(cachedProducts, prettyPrint: true)!
//        print("\nCachedProducts: \(result1Json)")
//        let result2Json = Mapper().toJSONString(tempList, prettyPrint: true)!
//        print("\nProducts: \(result2Json)")
        tempList = tempList.sorted(by: { $0.name.compare($1.name) == .orderedAscending})
        products = tempList
        reservedCollectionView.reloadData()
    }
    
    private func getSlidePhotos() {
        slidePhotos.removeAll()
        for i in cachedProducts {
            if !slidePhotos.contains(where: {$0 == i.id}){
                slidePhotos.append(i.photoUrls[0])
            }
        }
        reservedCollectionView.reloadData()
    }
    
    
    func fetchReservation() {
        guard let bizReservation = bizReservation else { return }
        reservationRef.document(bizReservation.id).getDocument { (document, error) in
            if let document = document, document.exists {
                let result = Mapper<Reservation>().map(JSONObject: document.data())!
                self.bizReservation.updateData(reservation: result)
                self.reservedCollectionView.reloadData()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func startDecline() {
        alertController = displaySpinner(title: "Processing..")
        declineReservation().then { (check) in
            self.alertController.dismiss(animated: true, completion: nil)
            if check {
                self.fetchReservation()
                self.alertHelper.showAlert(title: "Notice", alert: "Your have declined a reservation successfully", controller: self)
            }

        }
    }
    
    func startFailure() {
        alertController = displaySpinner(title: "Processing..")
        failingProducts()
    }
    
    private func failingProducts() {
        guard let bizReservation = bizReservation else { return }
        let productIds = getProductIds(bizReservation: bizReservation)
        fetchCachedProducts(productIds: productIds).then { (cachedProducts) in
            self.cachedProducts = cachedProducts
            self.getSlidePhotos()
            self.getProducts()
            for i in bizReservation.products {
                if let product = cachedProducts.first(where: {$0.id == i.productId}) {
                    if let variant = product.variants.first(where: {$0.color == i.variant.color && $0.size == i.variant.size }) {
                        variant.available = variant.available + i.variant.quantity
                    }
                    self.updateReservedProduct(productId: i.productId, variants: product.variants)
                }
            }
            self.updateProductAvailable()
            self.alertController.dismiss(animated: true, completion: nil)
            self.failReservation().then { (check) in
                if check {
                    self.fetchReservation()
                    self.alertHelper.showAlert(title: "Notice", alert: "Your customer has failed a reservation🥲", controller: self)
                }

            }
        }
    }
    
    func requestCancellation() {
        alertHelper.alertCancellation(controller: self)
    }
    
    func startCancellation() {
        alertController = displaySpinner(title: "Processing..")
        cancelingProducts()
    }
    
    private func cancelingProducts() {
        guard let bizReservation = bizReservation else { return }
        let productIds = getProductIds(bizReservation: bizReservation)
        fetchCachedProducts(productIds: productIds).then { (cachedProducts) in
            self.cachedProducts = cachedProducts
            self.getSlidePhotos()
            self.getProducts()
            for i in bizReservation.products {
                if let product = cachedProducts.first(where: {$0.id == i.productId}) {
                    if let variant = product.variants.first(where: {$0.color == i.variant.color && $0.size == i.variant.size }) {
                        variant.available = variant.available + i.variant.quantity
                    }
                    self.updateReservedProduct(productId: i.productId, variants: product.variants)
                }
            }
            self.updateProductAvailable()
            self.alertController.dismiss(animated: true, completion: nil)
            self.cancelReservation(storeId: bizReservation.businessId).then { (check) in
                if check {
                    self.fetchReservation()
                    self.alertHelper.showAlert(title: "Notice", alert: "Your have cancelled a reservation for your customer🥺", controller: self)
                }

            }
        }
    }
    
    func startCompletion() {
        alertController = displaySpinner(title: "Processing..")
        completingProducts()
    }
    
    private func completingProducts() {
        guard let bizReservation = bizReservation else { return }
        let productIds = getProductIds(bizReservation: bizReservation)
        fetchCachedProducts(productIds: productIds).then { (cachedProducts) in
            self.cachedProducts = cachedProducts
            self.getSlidePhotos()
            self.getProducts()
            for i in bizReservation.products {
                if let product = cachedProducts.first(where: {$0.id == i.productId}) {
                    if let variant = product.variants.first(where: {$0.color == i.variant.color && $0.size == i.variant.size }) {
                        variant.available = variant.available + i.variant.quantity
                    }
                    self.updateReservedProduct(productId: i.productId, variants: product.variants)
                }
            }
            self.updateProductAvailable()
            self.alertController.dismiss(animated: true, completion: nil)
            self.completedReservation().then { (check) in
                if check {
                    self.fetchReservation()
                    self.dispatchUpdateProduct()
                }

            }
        }
    }
    
    func startApproval() {
        let status = verifyReservation()
        if !status {
            alertHelper.showAlert(title: "Notice", alert: "Your timeslot or products have been taken, please choose other availability", controller: self)
        } else {
            alertController = displaySpinner(title: "Processing..")
            approvingProducts()
        }
    }
    
    private func approvingProducts() {
        guard let bizReservation = bizReservation else { return }
        let productIds = getProductIds(bizReservation: bizReservation)
        fetchCachedProducts(productIds: productIds).then { (cachedProducts) in
            self.cachedProducts = cachedProducts
            self.getSlidePhotos()
            self.getProducts()
            for i in bizReservation.products {
                if let product = cachedProducts.first(where: {$0.id == i.productId}) {
                    if let variant = product.variants.first(where: {$0.color == i.variant.color && $0.size == i.variant.size }) {
                        variant.available = variant.available - i.variant.quantity
                    }
                    self.updateReservedProduct(productId: i.productId, variants: product.variants)
//                    let resultJson = Mapper().toJSONString(product.variants, prettyPrint: true)!
//                    print("\nInformation: \(resultJson)")
                }
            }
            self.updateProductAvailable()
            self.alertController.dismiss(animated: true, completion: nil)
//            let resultJson = Mapper().toJSONString(cachedProducts, prettyPrint: true)!
//            print("\nCachedProducts: \(resultJson)")
            self.approveReservation().then { (check) in
                if check {
                    self.approveTimeslot()
                    self.fetchReservation()
                    self.alertHelper.showAlert(title: "Notice", alert: "Your approval to your customer is successful", controller: self)
                }
            }
        }
    }
    
    private func updateProductAvailable() {
        for i in cachedProducts {
            let total = i.variants.map({ $0.available }).reduce(0, +)
            dispatchAvailable(productId: i.id, available: total)
        }
    }
    
    func dispatchAvailable(productId: String, available: Int) {
        productRef.document(productId).updateData([
            "available": available,
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Updated product available successfully!")
            }
        }
    }
    
    private func approveTimeslot() {
        guard let reservation = self.bizReservation else { return }
        self.timeslotRef.document(reservation.timeslot.id).updateData([
            "isApproved": true
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Timeslot is approved successfully!")
            }
        }
    }
    
    func updateReservedProduct(productId: String, variants: [Variant]) {
        productRef.document(productId).updateData([
            "variants": variants.toJSON(),
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Updated product variants successfully!")
            }
        }
    }
    
    
    private func fetchCachedProducts(productIds: [String]) -> Promise<[Product]> {
        return Promise<[Product]>(in: .background) { (resolve, reject, _) in
            var tempList: [Product] = []
            for (_, element) in productIds.enumerated() {
                self.productRef.document(element).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let result = Mapper<Product>().map(JSONObject: document.data())!
                        tempList.append(result)
                    } else {
                        print("Document does not exist")
                    }
                    
                    if tempList.count == productIds.count {
                        resolve(tempList)
                    }
                }
            }
        }
    }
    
    private func getProductIds(bizReservation: BizReservation) -> [String] {
        var tempList: [String] = []
        for i in bizReservation.products {
            if !tempList.contains(where: {$0 == i.productId}){
                tempList.append(i.productId)
            }
        }
        return tempList
    }
    
    private func completedReservation() -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let reservation = self.bizReservation else {
                resolve(false)
                return
            }
            self.reservationRef.document(reservation.id).updateData([
                "status": "Completed",
                "completedAt": Date().iso8601withFractionalSeconds
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    resolve(false)
                } else {
                    print("Completed reservation successfully!")
                    resolve(true)
                }
            }
        }
    }
    
    private func approveReservation() -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let reservation = self.bizReservation else {
                resolve(false)
                return
            }
            self.reservationRef.document(reservation.id).updateData([
                "status": "Approved",
                "approvedAt": Date().iso8601withFractionalSeconds
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    resolve(false)
                } else {
                    print("Approved reservation successfully!")
                    resolve(true)
                }
            }
        }
    }
    
    private func declineReservation() -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let reservation = self.bizReservation else {
                resolve(false)
                return
            }
            self.reservationRef.document(reservation.id).updateData([
                "status": "Declined"
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    resolve(false)
                } else {
                    print("Declined reservation successfully!")
                    resolve(true)
                }
            }
        }
    }
    
    private func failReservation() -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let reservation = self.bizReservation else {
                resolve(false)
                return
            }
            self.reservationRef.document(reservation.id).updateData([
                "status": "Failed"
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    resolve(false)
                } else {
                    print("failed reservation successfully!")
                    resolve(true)
                }
            }
        }
    }
    
    private func cancelReservation(storeId: String) -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let reservation = self.bizReservation else {
                resolve(false)
                return
            }
            self.reservationRef.document(reservation.id).updateData([
                "status": "Canceled",
                "canceledBy": storeId,
                "canceledAt": Date().iso8601withFractionalSeconds,
                "isCanceled": true
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    resolve(false)
                } else {
                    print("canceled reservation successfully!")
                    resolve(true)
                }
            }
        }
    }
    
    @IBAction func handleAction(_ sender: Any?) {
        let statuses: [String] = ["Pending", "Approved", "Completed", "Failed", "Canceled", "Declined"]
        guard let bizReservation = bizReservation else { return }
        if bizReservation.status == statuses[0] {
            alertHelper.alertPending(controller: self)
        } else if bizReservation.status == statuses[1] {
            alertHelper.alertApprove(controller: self)
        } else if bizReservation.status == statuses[2] {
            alertHelper.alertComplete(controller: self)
        } else {
            alertHelper.alertOther(controller: self)
        }
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func setupNavItems() {
        
        if isFromBizReservation {
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
        } else {
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
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
}

extension ReservedProductController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reservedSlideCell, for: indexPath) as! ReservedSlideCell
        header.slidePhotos = slidePhotos
        headerSlide = header
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        if indexPath.row == 0 {
            return CGSize(width: width, height: 255)
        } else {
            return CGSize(width: width, height: 145)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reservedInfoCell, for: indexPath) as! ReservedInfoCell
            cell.reservation = bizReservation
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reservedProductCell, for: indexPath) as! ReservedProductCell
            cell.reserveState = bizReservation.status
            cell.product = products[indexPath.item - 1]
            return cell
        } 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            guard let user = user else { return }
            let controller = CustomerController()
            controller.userId = user.id
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerSlide?.scrollViewDidScroll(scrollView)
        floatingSlide.scrollViewDidScroll(scrollView)
    }
    
}
