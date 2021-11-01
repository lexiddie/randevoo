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

class ProductDetailController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ProductDetailTitleDelegate {
    
    private let db = Firestore.firestore()
    
    var productId: String!
    var currentProduct: Product!
    var personalAccount: PersonalAccount!
    var currentProductBiz: BusinessAccount!
    
    var imageSlide = ImageSlideshow()
    var productName = UILabel()
    var productPrice = UILabel()
    var sizeLabel = UILabel()
    var favorite = UIButton()
    var mainCollectionView: UICollectionView!
    var name: String = ""
    var price: String = ""
    var imageView: String = ""
    let imageSlideHeaderID = "ImageSlideHeaderCell"
    var headerView: ImageSlideHeaderCell?
    let productDetailTitileCell = "ProductDetailTitileCell"
    let productSizeCell = "aboutSizeCell"
    let productColorCell = "aboutColorCell"
    let productDescriptionCellD = "ProductDetailDescriptionCell"
    let productOwnerID = "ProductDetailOwnerCell"
    let demoInput:[InputType] = [InputType(type: "title", content: "Some titille"),  InputType(type: "color", content: "Color"), InputType(type: "size", content: "Size"), InputType(type: "description", content: "description"), InputType(type: "owner", content: "owner")]
    var dismissInteractivelySwitch: UISwitch!
    var viewTranslation = CGPoint(x: 0, y: 0)
    var isFromLiked = false
    var likeController: UIViewController?
    let textView = UITextView()
    var currentSizes: [String] = []
    var currentColors: [String] = []
    let addToLikeHelper = AddToLikeHelper()
    let alert = AlertHelper()
    var inLike = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialCollectView()
        fetchPersonalAcc()
        fetchingProduct()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.isOpaque = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func initialView() {
        let view = ProductDetailView(frame: self.view.frame)
        mainCollectionView = view.mainCollectionView
        if !isPersonalAccount {
            view.addToLikeButton.isHidden = true
            view.viewListButton.isHidden = true
            view.bottomView.snp.makeConstraints{(make) in
                make.height.equalTo(0)
            }
        }
        self.view = view
    }
    
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let width = 50
        let height = 30
        layout.itemSize = CGSize(width: width, height: height)
        return layout
    }()
    
    
    private func fetchingProduct() {
        let productRef = self.db.collection("products")
        productRef.document(productId).getDocument { (document, error) in
            if let document = document, document.exists {
                let result = Mapper<Product>().map(JSONObject: document.data())!
                self.currentProduct = result
                self.fetchingBiz(bizId: result.businessId)
                self.getInformation()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func fetchingBiz(bizId: String) {
        let businessRef = self.db.collection("businesses")
        businessRef.document(bizId).getDocument { (document, error) in
            if let document = document, document.exists {
                let result = Mapper<BusinessAccount>().map(JSONObject: document.data())!
                self.currentProductBiz = result
                self.mainCollectionView.reloadData()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func fetchPersonalAcc() {
        if let personalCache: PersonalAccount = FCache.get("personal"), !FCache.isExpired("personal") {
            self.personalAccount = personalCache
        }
    }
    
    private func initialCollectView(){
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(ImageSlideHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: imageSlideHeaderID)
        mainCollectionView.register(ProductDetailTitileCell.self, forCellWithReuseIdentifier: productDetailTitileCell)
        mainCollectionView.register(ProductDetailSizeCell.self, forCellWithReuseIdentifier: productSizeCell)
        mainCollectionView.register(ProductDetailColorCell.self, forCellWithReuseIdentifier: productColorCell)
        mainCollectionView.register(ProductDetailDescriptionCell.self, forCellWithReuseIdentifier: productDescriptionCellD)
        mainCollectionView.register(ProductDetailOwnerCell.self, forCellWithReuseIdentifier: productOwnerID)
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        if isFromLiked {
            self.dismiss(animated: true, completion: {
                let currentController = self.likeController as! LikeCategoriesController
                currentController.retrieveLikeList()
            })
        } else {
            self.dismiss(animated: true, completion: nil)
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
    }
    
    let presenterForAddToList: Presentr = {
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
        guard let product = currentProduct else { return }
        for information in product.information {
            if !currentSizes.contains(information.size) {
                currentSizes.append(information.size)
            }
            if !currentColors.contains(information.color) {
                currentColors.append(information.color)
            }
        }
        self.checkIfProductInLike()
        self.mainCollectionView.reloadData()
    }
    
    @IBAction func showViewControllerTapped(_ sender: UIButton) {
        let popupVC = AddToListController()
        popupVC.currentProduct = currentProduct
        popupVC.currentColors = currentColors
        popupVC.currentSizes = currentSizes
        let navController = UINavigationController(rootViewController: popupVC)
        customPresentViewController(presenterForAddToList, viewController: navigationController, animated: true, completion: nil)
    }
    
    let presenterForAddToLike: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.fluid(percentage: 0.8)
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
    
    func addToLikePopup() {
        let likeController = LikePopUpController()
        let navController = UINavigationController(rootViewController: likeController)
        customPresentViewController(presenterForAddToLike, viewController: navigationController, animated: true, completion: nil)
    }
    
    func addToLikeList() {
        if personalAccount != nil {
            let like = db.collection("saves")
            let likeId = like.document().documentID
            let currentLike = Save(id: likeId, productId: currentProduct.id, userId: personalAccount.id)
            if var likeList: [Save] = FCache.get("saves"), !FCache.isExpired("saves") {
                print(likeList.count)
                if !likeList.contains(where: {$0.productId == currentLike.productId}) {
                    likeList.append(currentLike)
                    addLikeToDb(like: currentLike, likeList: likeList)
                } else {
                    let alertController = UIAlertController(title: "Liked List", message: "Remove From Like List ?", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        self.removeProductFromLike(likedList: likeList, currentProductId: self.currentProduct.id)
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
    }
    
    func removeProductFromLike(likedList: [Save], currentProductId: String){
        let newList = likedList.filter({ $0.productId != currentProductId })
        let removeList = likedList.filter({ $0.productId == currentProductId })
        addLikeToLocal(likeList: newList)
        checkIfProductInLike()
        if removeList.count != 0 {
            addToLikeHelper.removeLikeFromDb(id: removeList[0].id)
        }
        self.mainCollectionView.reloadData()

    }
    
    private func addLikeToDb(like: Save, likeList: [Save]) {
        FCache.set(likeList, key: "saves")
        addToLikeHelper.saveLikeToDb(like: like)
        let success = alert.displaySuccessAlert(msg: "Successfully add to List", controller: self)
        checkIfProductInLike()
//        let deadlineTime = DispatchTime.now() + .seconds(1)
        let deadlineTime = DispatchTime.now()
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            success.dismiss(animated: true, completion: nil)
            self.mainCollectionView.reloadData()
        }
    }
    
    private func addLikeToLocal(likeList: [Save]) {
        FCache.set(likeList, key: "saves")

    }
    
    private func checkIfProductInLike() {
        if let likeList: [Save] = FCache.get("saves"), !FCache.isExpired("saves") {
            if likeList.contains(where: {$0.productId == currentProduct.id}) {
                inLike = true
            } else {
                inLike = false
            }
        } else {
            inLike = false
        }
    }
        
    @IBAction func showAddToLike (_ sender: UIButton) {
        
    }
    
    
    @IBAction func viewAddNew (_ sender: UIButton) {
    }
    
    @IBAction func viewList(){
        let listController = ListDetailsController()
        navigationController?.pushViewController(listController, animated: true)
    }
    
    @IBAction func viewLikedList(){
        let likeController = LikeCategoriesController()
        navigationController?.pushViewController(likeController, animated: true)
    }
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            print("Swipe down work")
            viewTranslation = sender.translation(in: view)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
            })
        case .ended:
            if viewTranslation.y < 200 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
}

extension ProductDetailController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        if demoInput[indexPath.row].type == "title" {
            let font = UIFont(name: "Quicksand-Regular", size: 16)!
            let descriptionWidth = view.frame.width - 80
            var heightOfText = 0.0 as Float
            if currentProduct != nil {
                heightOfText = Float(currentProduct.name.heightWithConstrainedWidth(width: descriptionWidth, font: font))
            }
            return CGSize(width: width, height: CGFloat(heightOfText) + 40)
        } else if demoInput[indexPath.row].type == "size" {
            return CGSize(width: width, height: 90)
        } else if demoInput[indexPath.row].type == "color"{
            return CGSize(width: width, height: 90)
        } else if demoInput[indexPath.row].type == "owner"{
            return CGSize(width: width, height: 100)
        } else {
            let font = UIFont(name: "Quicksand-Regular", size: 15)!
            let descriptionWidth = view.frame.width - 40
            var heightOfText = 0.0 as Float
            if currentProduct != nil {
                heightOfText = Float(currentProduct.description.heightWithConstrainedWidth(width: descriptionWidth, font: font))
            }
            let height = heightOfText
            return CGSize(width: descriptionWidth, height: CGFloat(height) + 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: imageSlideHeaderID, for: indexPath) as! ImageSlideHeaderCell
        header.product = currentProduct
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = (view.frame.width)
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
        return demoInput.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if demoInput[indexPath.row].type == "title" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productDetailTitileCell, for: indexPath) as! ProductDetailTitileCell
            cell.product = currentProduct
            if inLike {
                cell.favorite.setImage(UIImage.init(named: "LikedIcon"), for: .normal)
            } else {
                cell.favorite.setImage(UIImage.init(named: "LikeIcon"), for: .normal)
            }
            cell.delegate = self
            return cell
        } else if demoInput[indexPath.row].type == "size" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productSizeCell, for: indexPath) as! ProductDetailSizeCell
            cell.sizeList = currentSizes
            return cell
        } else if demoInput[indexPath.row].type == "color"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productColorCell, for: indexPath) as! ProductDetailColorCell
            cell.colorList = currentColors
            return cell
        } else if demoInput[indexPath.row].type == "description" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productDescriptionCellD, for: indexPath) as! ProductDetailDescriptionCell
            cell.product = currentProduct
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productOwnerID, for: indexPath) as! ProductDetailOwnerCell
            cell.business = currentProductBiz
            return cell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerView?.scrollViewDidScroll(scrollView)
    }
    
}

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                     attributes: [NSAttributedString.Key.font: self],
                                                     context: nil).size
    }
}

extension String {
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}





