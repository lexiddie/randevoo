//
//  ReservationDetailController.swift
//  randevoo
//
//  Created by Xell on 28/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit
import ImageSlideshow
import ObjectMapper
import AlamofireImage
import FirebaseFirestore

class ReservationDetailController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ReservationDetailDelegate{

    var shopImg: UIImageView?
    var mainCollectionView: UICollectionView!
    let reservationDetailCell = "reservationDetailCell"
    let reservationProductCell = "ReservationProductCell"
    let productImageSlideCell = "productImageSlideCell"
    private var reservationRef: CollectionReference!
    var tempProducts : [TempProduct] = []
    var totalLabel: UILabel!
    var headerView: ProductImageSlideCell?
    var floatingHeaderView = ProductImageSlideCell()
    var timeslot: Timeslot!
    var reserveProduct: Reservation!
    var storeAccount: BusinessAccount!
    let db = Firestore.firestore()
    var productList: [Product] = []
    let numberFormatter = NumberFormatter()
    
    private var slidePhotos: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initiateFirestore()
        initialCollectView()
        retrieveProduct()
        fetchRealTimeReservation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func initialView() {
        let view = ReservationDetailView(frame: self.view.frame)
        mainCollectionView = view.mainCollectionView
        totalLabel = view.total
        self.view = view
    }
    
    private func initiateFirestore() {
        reservationRef = db.collection("reservations")
    }
    
    private func initialCollectView(){
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(ProductImageSlideCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: productImageSlideCell)
        mainCollectionView.register(ReservationDetailTitleCell.self, forCellWithReuseIdentifier: reservationDetailCell)
        mainCollectionView.register(ReservationDetailProductCell.self, forCellWithReuseIdentifier: reservationProductCell)
    }
    
    private func loadTempProduct() {
        let currentData = Mapper<TempProduct>().mapArray(JSONfile: "StoreData.json")! as [TempProduct]
        tempProducts = Array(currentData.prefix(upTo: 5))
        tempProducts.append(TempProduct(id: "a", name: "a", imageUrl: "", price: 0.0))
        tempProducts = tempProducts.sorted(by: {$0.name < $1.name})
        mainCollectionView.reloadData()
        mainCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleShowQr(_ sender: Any?) {
        let qrController = QrCodeController()
        qrController.modalPresentationStyle = .overCurrentContext
        qrController.reservationCode = reserveProduct.qrCode
        let navController = UINavigationController(rootViewController: qrController)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.barTintColor = UIColor.clear
        present(navController, animated: true, completion: nil)
        
    }

    
    private func setupNavItems() {
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController!.navigationBar.isTranslucent = true
        
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
        
        let qrButton = UIButton(type: .system)
        qrButton.setImage(UIImage(named: "QrCodeIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        qrButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        qrButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        qrButton.contentHorizontalAlignment = .center
        qrButton.contentVerticalAlignment = .center
        qrButton.contentMode = .scaleAspectFit
        qrButton.backgroundColor = UIColor.white
        qrButton.layer.cornerRadius = 8
        qrButton.addTarget(self, action: #selector(handleShowQr(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: qrButton)
        qrButton.snp.makeConstraints{ (make) in
            make.height.width.equalTo(40)
        }
    }
    
    private func retrieveProduct() {
        let productCollection = db.collection("products")
        for product in reserveProduct.products {
            productCollection.whereField("id", isEqualTo: product.productId!).getDocuments() { [self](querySnapShot, err) in
                if err != nil {
                    print("Failed to Retrieve Timeslot")
                } else {
                    for document in querySnapShot!.documents{
                        let currentData = Mapper<Product>().map(JSONObject: document.data())
                        self.productList.append(currentData!)
                    }
                    getSlidePhotos()
                    mainCollectionView.reloadData()
                    setupTotalPrice()
                }
            }
        }
    }
    
    private func setupTotalPrice(){
        var totalPrice = 0.0
        for reserve in reserveProduct.products {
            let currentProduct = productList.filter({$0.id == reserve.productId})
            if currentProduct.count > 0 {
                totalPrice += Double(reserve.variant.quantity) * currentProduct[0].price
            }
        }
        numberFormatter.numberStyle = .decimal
        let priceFormat = numberFormatter.string(from: NSNumber(value: totalPrice))
        totalLabel.text = "Total: ฿\(String(priceFormat!))"
    }
    
    private func fetchRealTimeReservation(){
        print("run real time data")
        guard let personal = personalAccount else {
            print("Personal Info is empty in reservation")
            return
        }
        reservationRef.whereField("id", isEqualTo: reserveProduct.id).addSnapshotListener() { (querySnapShot, err) in
            if err != nil {
                print("Failed to Retrieve User Reservation")
            } else {
                for document in querySnapShot!.documents {
                    let currentData = Mapper<Reservation>().map(JSONObject: document.data())
                    self.reserveProduct = currentData
                    self.mainCollectionView.reloadData()
                }

            }
        }
    }
    
    func viewStore() {
        let controller = StoreController()
        controller.storeId = storeAccount.id
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func getSlidePhotos() {
        slidePhotos.removeAll()
        for i in productList {
            if !slidePhotos.contains(where: {$0 == i.id}){
                slidePhotos.append(i.photoUrls[0])
            }
        }
        self.mainCollectionView.reloadData()
    }
    
}

extension ReservationDetailController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            let height = view.frame.width / 2 + 70
            return CGSize(width: view.frame.width, height: height)
        } else {
            let height = view.frame.width / 3
            return CGSize(width: view.frame.width, height: height + 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: productImageSlideCell, for: indexPath) as! ProductImageSlideCell
        header.slidePhotos = slidePhotos
        self.headerView = header
        return header
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 350)
    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    //        return CGSize(width: view.frame.width, height: 50)
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    //        return 5
    //    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    //        return 5
    //    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reserveProduct.products.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reservationDetailCell, for: indexPath) as! ReservationDetailTitleCell
            if storeAccount != nil && reserveProduct != nil && timeslot != nil{
                if storeAccount.isBanned {
                    cell.shopName.setTitleColor(UIColor.randevoo.mainRed, for: .normal)
                    cell.isBanned = true
                } else {
                    cell.shopName.setTitleColor(UIColor.randevoo.mainBlack, for: .normal)
                    cell.isBanned = false
                }
                cell.shopName.setTitle(storeAccount.name, for: .normal)
                cell.reservationStatus.text = reserveProduct.status
                if reserveProduct.status.lowercased() == "succeed" {
                    cell.statusView.backgroundColor = UIColor.randevoo.mainStatusGreen.withAlphaComponent(0.3)
                    cell.reservationStatus.textColor = UIColor.randevoo.mainStatusGreen
                }else if reserveProduct.status.lowercased() == "approved"{
                    cell.reservationStatus.textColor = UIColor.randevoo.mainColor
                    cell.statusView.backgroundColor = UIColor.randevoo.mainColor.withAlphaComponent(0.3)
                }else if reserveProduct.status.lowercased() == "pending"{
                    cell.reservationStatus.textColor = UIColor.randevoo.mainStatusYellow
                    cell.statusView.backgroundColor = UIColor.randevoo.mainStatusYellow.withAlphaComponent(0.3)
                } else if reserveProduct.status.lowercased() == "completed"{
                    cell.statusView.backgroundColor = UIColor.randevoo.mainStatusGreen.withAlphaComponent(0.3)
                    cell.reservationStatus.textColor = UIColor.randevoo.mainStatusGreen
                }else if reserveProduct.status.lowercased() == "failed"{
                    cell.reservationStatus.textColor = UIColor.randevoo.mainStatusRed
                    cell.statusView.backgroundColor = UIColor.randevoo.mainStatusRed.withAlphaComponent(0.3)
                }else if reserveProduct.status.lowercased() == "declined"{
                    cell.reservationStatus.textColor = UIColor.randevoo.mainStatusRed
                    cell.statusView.backgroundColor = UIColor.randevoo.mainStatusRed.withAlphaComponent(0.3)
                }else if reserveProduct.status.lowercased() == "Canceled"{
                    cell.reservationStatus.textColor = UIColor.randevoo.mainStatusRed
                    cell.statusView.backgroundColor = UIColor.randevoo.mainStatusRed.withAlphaComponent(0.3)
                }
                cell.delegate = self
                cell.shopImg.loadCacheImage(urlString: storeAccount.profileUrl)
                cell.id.text = reserveProduct.qrCode
                cell.scheduleDate.text = timeslot.date
                cell.scheduleTime.text = timeslot.time
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reservationProductCell, for: indexPath) as! ReservationDetailProductCell
            let currentProduct = productList.filter({$0.id == reserveProduct.products[indexPath.row - 1].productId})
            if currentProduct.count > 0 {
                cell.productImg.loadCacheImage(urlString: currentProduct[0].photoUrls[0])
                numberFormatter.numberStyle = .decimal
                let totalPrice = Double(reserveProduct.products[indexPath.row - 1].variant.quantity) * currentProduct[0].price
                let priceFormat = numberFormatter.string(from: NSNumber(value: totalPrice))
                cell.productPrice.text =  "฿\(String(priceFormat!))"
                cell.productName.text = currentProduct[0].name
                if (currentProduct[0].isBanned || !currentProduct[0].isActive) && reserveProduct.status != "Completed"{
                    if currentProduct[0].isBanned {
                        cell.background.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                        cell.isBannedLabel.text = "Product is currently Banned!"
                        cell.isBannedLabel.textColor = UIColor.randevoo.mainRed.withAlphaComponent(0.8)
                        cell.isBannedLabel.backgroundColor = UIColor.white
                    } else if !currentProduct[0].isActive && reserveProduct.status != "Approved" {
                        cell.background.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                        cell.isBannedLabel.text = "Product is currently Removed!"
                        cell.isBannedLabel.textColor = UIColor.randevoo.mainRed.withAlphaComponent(0.8)
                        cell.isBannedLabel.backgroundColor = UIColor.white
                    }
                } else {
                    cell.background.backgroundColor = .clear
                    cell.isBannedLabel.text = ""
                    cell.isBannedLabel.backgroundColor = .clear
                }
            }
            cell.productColor.text = reserveProduct.products[indexPath.row - 1].variant.color
            cell.productSize.text = reserveProduct.products[indexPath.row - 1].variant.size
            cell.productQuantity.text = "x \(String(reserveProduct.products[indexPath.row - 1].variant.quantity))"
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
//            let listingCategoryController = ListingCategoryController()
//            listingCategoryController.previousController = self
//            let navController = UINavigationController(rootViewController: listingCategoryController)
//            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerView?.scrollViewDidScroll(scrollView)
        floatingHeaderView.scrollViewDidScroll(scrollView)
    }
    
}

