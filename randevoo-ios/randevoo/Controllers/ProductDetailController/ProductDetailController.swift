//
//  ProductDetailController.swift
//  randevoo
//
//  Created by Xell on 10/11/2563 BE.
//  Copyright © 2563 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import ImageSlideshow
import Presentr
import AlamofireImage
import ObjectMapper
import SwiftyJSON
import Cache

class ProductDetailController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ProductTitleCellDelegate {
    
    var productId: String!

    private let db = Firestore.firestore()
    private var businessRef: CollectionReference!
    private var bizInfoRef: CollectionReference!
    private var productRef: CollectionReference!
    private var saveRef: CollectionReference!
    private var product: Product!
    private var storeAccount: StoreAccount!
    private var storeInfo: BizInfo!
    
    let addToLikeHelper = AddToLikeHelper()
    let alert = AlertHelper()

    private let productImageSlideCell = "productImageSlideCell"
    private let productTitleCell = "productTitleCell"
    private let productSizeCell = "productSizeCell"
    private let productColorCell = "productColorCell"
    private let productDescriptionCell = "productDescriptionCell"
    private let productStoreCell = "productStoreCell"
    private let productPolicyCell = "productPolicyCell"
    private let productMapCell = "productMapCell"
    var addToBagBtn: UIButton!
    var viewBagBtn: UIButton!
    
    var isFromSave = false
    var likeController: UIViewController?
    var productSizes: [String] = []
    var productColors: [String] = []
    
    private var slidePhotos: [String] = []

    var isSaved: Bool = false
    
    private var productDetailCollectionView: UICollectionView!
    private var headerSlide: ProductImageSlideCell?
    private var floatingSlide = ProductImageSlideCell()
    
    private var isFirst: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialCollectView()
        initiateFirestore()
        fetchingProduct()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
//        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func initialView() {
        let view = ProductDetailView(frame: self.view.frame)
        productDetailCollectionView = view.productDetailCollectionView
        viewBagBtn = view.viewBagButton
        addToBagBtn = view.addToBagButton
        if !isPersonalAccount {
            view.addToBagButton.isHidden = true
            view.viewBagButton.isHidden = true
            view.bottomView.snp.makeConstraints{(make) in
                make.height.equalTo(0)
            }
        }
        self.view = view
    }
    
    private func hideAddToList() {
        if !product.isActive || product.isBanned || product.available <= 0 || !product.isAvailable{
            viewBagBtn.isHidden = true
            addToBagBtn.isHidden = true
        } else {
            viewBagBtn.isHidden = false
            addToBagBtn.isHidden = false
        }
    }
    
    private func initiateFirestore() {
        businessRef = db.collection("businesses")
        bizInfoRef = db.collection("bizInfos")
        productRef = db.collection("products")
        saveRef = db.collection("saves")
    }
    
    func fetchingProduct() {
        isFirst = true
        productRef.document(productId).getDocument { (document, error) in
            if let document = document, document.exists {
                let result = Mapper<Product>().map(JSONObject: document.data())!
                self.product = result
                self.fetchStoreAccount(storeId: result.businessId)
                self.getInformation()
                self.getSlidePhotos()
                self.hideAddToList()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func loadUpdate() {
        if isFirst {
            productSizes = []
            productColors = []
            slidePhotos = []
            productDetailCollectionView.reloadData()
            fetchingProduct()
            productDetailCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    private func fetchStoreAccount(storeId: String) {
        businessRef.document(storeId).getDocument { (document, error) in
            if let document = document, document.exists {
                let result = Mapper<StoreAccount>().map(JSONObject: document.data())!
                self.storeAccount = result
                self.bizInfoRef.whereField("businessId", isEqualTo: result.id!).limit(to: 1).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting variant documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                let record = Mapper<BizInfo>().map(JSONObject: document.data())!
                                self.storeInfo = record
                                self.productDetailCollectionView.reloadData()
                            }
                        }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func initialCollectView(){
        productDetailCollectionView.delegate = self
        productDetailCollectionView.dataSource = self
        productDetailCollectionView.register(ProductImageSlideCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: productImageSlideCell)
        productDetailCollectionView.register(ProductTitleCell.self, forCellWithReuseIdentifier: productTitleCell)
        productDetailCollectionView.register(ProductSizeCell.self, forCellWithReuseIdentifier: productSizeCell)
        productDetailCollectionView.register(ProductColorCell.self, forCellWithReuseIdentifier: productColorCell)
        productDetailCollectionView.register(ProductDescriptionCell.self, forCellWithReuseIdentifier: productDescriptionCell)
        productDetailCollectionView.register(ProductStoreCell.self, forCellWithReuseIdentifier: productStoreCell)
        productDetailCollectionView.register(ProductPolicyCell.self, forCellWithReuseIdentifier: productPolicyCell)
        productDetailCollectionView.register(ProductMapCell.self, forCellWithReuseIdentifier: productMapCell)
    }
    
    let presenter: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.fluid(percentage: 1)
        let center = ModalCenterPosition.bottomCenter
        let presentr = Presentr(presentationType: .custom(width: width, height: height, center: center))
        presentr.roundCorners = true
        presentr.cornerRadius = 15
        presentr.backgroundColor = UIColor.black
        presentr.backgroundOpacity = 0.7
        presentr.transitionType = .coverVertical
        presentr.dismissTransitionType = .coverVertical
        presentr.dismissOnSwipe = true
        presentr.dismissAnimated = true
        presentr.dismissOnSwipeDirection = .default
        return presentr
    }()
    
    private func getInformation(){
        productColors.removeAll()
        productSizes.removeAll()
        guard let product = product else { return }
        for information in product.variants {
            if !productSizes.contains(information.size) {
                productSizes.append(information.size)
            }
            if !productColors.contains(information.color) {
                productColors.append(information.color)
            }
        }
        self.checkProductIsLiked()
        self.productDetailCollectionView.reloadData()
    }
    
    func addToLikeList() {
        guard let product = product else { return }
        guard let personal = personalAccount else { return }
        let saveId = saveRef.document().documentID
        let currentLike = Save(id: saveId, productId: product.id, userId: personal.id)
        if var likeList: [Save] = FCache.get("saves"), !FCache.isExpired("saves") {
            print(likeList.count)
            if !likeList.contains(where: {$0.productId == currentLike.productId}) {
                likeList.append(currentLike)
                addLikeToDb(like: currentLike, likeList: likeList)
            } else {
                let alertController = UIAlertController(title: "Liked List", message: "Remove From Like List ?", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.removeProductFromLike(likedList: likeList, currentProductId: self.product.id)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(alertAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            var likeArray: [Save] = []
            likeArray.append(currentLike)
            addLikeToDb(like: currentLike, likeList: likeArray)
        }
    }
    
    func removeProductFromLike(likedList: [Save], currentProductId: String){
        let newList = likedList.filter({ $0.productId != currentProductId })
        let removeList = likedList.filter({ $0.productId == currentProductId })
        addLikeToLocal(likeList: newList)
        checkProductIsLiked()
        if removeList.count != 0 {
            addToLikeHelper.removeLikeFromDb(id: removeList[0].id)
        }
        self.productDetailCollectionView.reloadData()
    }
    
    private func addLikeToDb(like: Save, likeList: [Save]) {
        FCache.set(likeList, key: "saves")
        addToLikeHelper.saveLikeToDb(like: like)
        let success = alert.displaySuccessAlert(msg: "Successfully add to List", controller: self)
        checkProductIsLiked()
        let deadlineTime = DispatchTime.now()
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            success.dismiss(animated: true, completion: nil)
            self.productDetailCollectionView.reloadData()
        }
    }
    
    private func addLikeToLocal(likeList: [Save]) {
        FCache.set(likeList, key: "saves")
    }
    
    private func checkProductIsLiked() {
        if let likeList: [Save] = FCache.get("saves"), !FCache.isExpired("saves") {
            if likeList.contains(where: {$0.productId == product.id}) {
                isSaved = true
            } else {
                isSaved = false
            }
        } else {
            isSaved = false
        }
    }
    
    @IBAction func handleAddToBag(_ sender: UIButton) {
        let controller = AddToListController()
        controller.currentProduct = product
        let navController = UINavigationController(rootViewController: controller)
        customPresentViewController(presenter, viewController: navController, animated: true, completion: nil)
    }
    
    @IBAction func handleViewBag(_ sender: Any?) {
        let controller = ListDetailsController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        if isFromSave {
            self.navigationController?.dismiss(animated: true, completion: {
//                let currentController = self.likeController as! SaveController
//                currentController.fetchSaves()
            })
        } else {
            self.dismiss(animated: true) {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
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
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
//        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            self.navigationController?.navigationBar.isOpaque = true
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
            self.navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
            self.navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        } else {
            self.navigationController?.navigationBar.isOpaque = true
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
            self.navigationController?.navigationBar.backgroundColor = UIColor.clear
            self.navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        }
    }
    
    private func getSlidePhotos() {
        guard let product = product else { return }
        slidePhotos.removeAll()
        slidePhotos = product.photoUrls
        self.productDetailCollectionView.reloadData()
    }
}

extension ProductDetailController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        if indexPath.item == 0 {
            let font = UIFont(name: "Quicksand-Bold", size: 17)!
            let textWidth = view.frame.width - 80
            var heightOfText = 0.0 as Float
            if product != nil {
                heightOfText = Float(product.name.heightWithConstrainedWidth(width: textWidth, font: font))
            }
            return CGSize(width: width, height: CGFloat(heightOfText) + 80)
        } else if indexPath.item == 1 {
            if productColors.count == 1 && productColors[0] == "None" {
                return CGSize(width: width, height: 0)
            }
            return CGSize(width: width, height: 90)
        } else if indexPath.item == 2 {
            if productSizes.count == 1 && productSizes[0] == "None" {
                return CGSize(width: width, height: 0)
            }
            return CGSize(width: width, height: 90)
        } else if indexPath.item == 4 {
            return CGSize(width: width, height: 110)
        } else if indexPath.item == 5 {
            let font = UIFont(name: "Quicksand-Medium", size: 16)!
            let textWidth = view.frame.width - 40
            var heightOfText = 0.0 as Float
            if storeInfo != nil {
                heightOfText = Float(storeInfo.policy.heightWithConstrainedWidth(width: textWidth, font: font))
            }
            return CGSize(width: width, height: CGFloat(heightOfText) + 50)
        } else if indexPath.item == 6 {
            return CGSize(width: width, height: width + 40)
        } else {
            let font = UIFont(name: "Quicksand-Medium", size: 16)!
            let textWidth = view.frame.width - 40
            var heightOfText = 0.0 as Float
            if product != nil {
                heightOfText = Float(product.description.heightWithConstrainedWidth(width: textWidth, font: font))
            }
            return CGSize(width: width, height: CGFloat(heightOfText) + 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: productImageSlideCell, for: indexPath) as! ProductImageSlideCell
        header.slidePhotos = slidePhotos
        headerSlide = header
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productTitleCell, for: indexPath) as! ProductTitleCell
            cell.product = product
            cell.isSaved = isSaved
            cell.delegate = self
            return cell
        } else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productColorCell, for: indexPath) as! ProductColorCell
            cell.colorList = productColors
            return cell
        } else if indexPath.item == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productSizeCell, for: indexPath) as! ProductSizeCell
            cell.sizeList = productSizes
            return cell
        } else if indexPath.item == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productDescriptionCell, for: indexPath) as! ProductDescriptionCell
            cell.product = product
            return cell
        } else if indexPath.item == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productStoreCell, for: indexPath) as! ProductStoreCell
            cell.store = storeAccount
            return cell
        } else if indexPath.item == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productPolicyCell, for: indexPath) as! ProductPolicyCell
            cell.storeInfo = storeInfo
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productMapCell, for: indexPath) as! ProductMapCell
            cell.storeInfo = storeInfo
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 4 {
            let controller = StoreController()
            controller.storeId = storeAccount.id
            navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.item == 6 {
            let controller = StoreMapController()
            controller.storeAccount = storeAccount
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerSlide?.scrollViewDidScroll(scrollView)
        floatingSlide.scrollViewDidScroll(scrollView)
    }
}
