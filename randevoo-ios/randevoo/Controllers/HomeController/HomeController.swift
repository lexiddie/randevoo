//
//  HomeController.swift
//  randevoo
//
//  Created by Lex on 18/5/20.
//  Copyright © 2020 Lex. All rights reserved.
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
import Presentr
import NVActivityIndicatorView

let diskConfig = DiskConfig(name: "randevoo")
let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

let storage = try? Storage(diskConfig: diskConfig,
                           memoryConfig: memoryConfig,
                           transformer: TransformerFactory.forData())

public class FCache {
    public static func set<T: Codable>(_ value: T, key: String, expiry: Expiry? = nil) {
        let typeStorage = storage?.transformCodable(ofType: T.self)
        try? typeStorage?.setObject(value, forKey: key, expiry: expiry)
    }
    
    public static func get<T: Codable>(_ key: String) -> T? {
        let typeStorage = storage?.transformCodable(ofType: T.self)
        return try? typeStorage?.object(forKey: key)
    }
    
    public static func setImage(image: UIImage, key: String, expiry: Expiry? = nil) {
        let imageStorage = storage?.transformImage()
        try? imageStorage?.setObject(image, forKey: key, expiry: expiry)
    }
    
    public static func getImage(key: String) -> UIImage? {
        let imageStorage = storage?.transformImage()
        return try? imageStorage?.object(forKey: key)
    }
    
    public static func isExpired(_ key: String) -> Bool {
        if let b = try? storage?.isExpiredObject(forKey: key) {
            return b
        }
        return true
    }
}

class TempData: Mappable, Codable {
    
    var name: String! = ""
    var position: String! = ""
    var createdAt: String! = ""
    
    init(name: String, position: String, createdAt: String) {
        self.name = name
        self.position = position
        self.createdAt = createdAt
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name <- map["name"]
        position <- map["position"]
        createdAt <- map["createdAt"]
    }
}


class HomeController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    private let db = Firestore.firestore()
    private var productRef: CollectionReference!
    private var businessRef: CollectionReference!
    
    var mainTabBar: UITabBar!
    
    private let defaults = UserDefaults.standard
    private let timestampHelper = TimestampHelper()
    private let homeProductCell = "homeProductCell"
    private let filterCell = "filterHeaderCell"
    private var products: [ListProduct] = []
    private var categories: [Category] = []
    private var selectedCategories: [Category] = []
    
    private var refreshControl = UIRefreshControl()
    private var friendlyLabel: UILabel!
    private var productCollectionView: UICollectionView!
    private var categoryCollectionView: UICollectionView!
    private var selectCategoryButton: UIButton!
    
    private var isDescending = true
    private var priceDescending: Bool?
    var isFilter = false
    private var minMax: Bool?
    private var filterMinPrice = 0
    private var filterMaxPrice = 0
    let alertHelper = AlertHelper()
    
    private var loading: NVActivityIndicatorView!
    
    lazy var homeCategoryView: HomeCategoryView = {
        let view = HomeCategoryView()
        view.homeController = self
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialCollectionView()
        initiateFirestore()
        loadProducts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let mainTabBarController = self.tabBarController as! MainTabBarController
        mainTabBar = mainTabBarController.tabBar
        mainTabBar.isHidden = false
        
        refreshControl.endRefreshing()
        
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func initialView() {
        let view = HomeView(frame: self.view.frame)
        self.productCollectionView = view.productCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.loading = view.loading
        self.view = view
        self.view.addSubview(homeCategoryView)
        self.categoryCollectionView = homeCategoryView.categoryCollectionView
        self.selectCategoryButton = homeCategoryView.selectCategoryButton
        self.productCollectionView.backgroundColor = UIColor.randevoo.mainLight
        homeCategoryView.snp.makeConstraints { (make) in
            make.top.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(50)
            make.left.right.lessThanOrEqualTo(self.view)
        }
        let mainTabBarController = self.tabBarController as! MainTabBarController
        mainTabBar = mainTabBarController.tabBar
    }
    
    private func initiateFirestore() {
        productRef = db.collection("products")
        businessRef = db.collection("businesses")
    }
    
    private func initialCollectionView() {
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        productCollectionView.register(FilterHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: filterCell)
        productCollectionView.register(HomeProductCell.self, forCellWithReuseIdentifier: homeProductCell)
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: UIControl.Event.valueChanged)
        productCollectionView.addSubview(refreshControl)
    }
    
    private func loadFriendlyLabel() {
        if products.count == 0 {
            friendlyLabel.text = "Wow, such empty, please check your internet connection😫"
        } else {
            friendlyLabel.text = nil
        }
    }
    
    @IBAction func refreshList(_ sender: Any?) {
        if minMax != nil {
            if minMax! {
                reloadProductByPriceRange()
            } else {
                reloadOnlyWithMin()
            }
        } else if priceDescending == nil {
            loadProducts()
        } else {
            reloadProducts()
        }
        
    }
    
    private func loadProducts() {
        loading.startAnimating()
        fetchProducts().then { (check) in
            if (check) {
                self.fetchingStores()
                self.loading.stopAnimating()
            }
        }
    }
    
    private func fetchingStores() {
        for i in products {
            if let bizCache: ListingBiz = FCache.get(i.businessId), !FCache.isExpired(i.businessId) {
                i.bizProfileUrl = bizCache.bizProfileUrl
                i.bizName = bizCache.bizName
                i.bizUsername = bizCache.bizUsername
                i.bizLocation = bizCache.bizLocation
                self.productCollectionView.reloadData()
            } else {
                businessRef.document(i.businessId).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let result = Mapper<StoreAccount>().map(JSONObject: document.data())!
                        let current = ListingBiz(businessId: result.id, bizName: result.name, bizUsername: result.username, bizProfileUrl: result.profileUrl, bizLocation: result.location)
                        FCache.set(current, key: result.id, expiry: .seconds(60 * (10)))
                        i.bizName = result.name
                        i.bizUsername = result.username
                        i.bizProfileUrl = result.profileUrl
                        i.bizLocation = result.location
                        self.productCollectionView.reloadData()
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
    
    private func fetchProducts() -> Promise<Bool>  {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.productRef
                .whereField("isActive", isEqualTo: true)
                .whereField("isBanned", isEqualTo: false)
                .whereField("isAvailable", isEqualTo: true)
                .order(by: "createdAt", descending: self.isDescending)
                .limit(to: 30)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        self.refreshControl.endRefreshing()
                        resolve(false)
                    } else {
                        var tempList: [ListProduct] = []
                        for document in querySnapshot!.documents {
                            let product = Mapper<Product>().map(JSONObject: document.data())!
                            let subcategory = gSubcategories.filter({$0.id == product.subcategoryId})
                            if subcategory.count != 0 {
                                let listProduct = ListProduct(id: product.id, businessId: product.businessId, name: product.name, price: product.price, category: subcategory[0].category.name, subcategory: subcategory[0].name, photoUrl: product.photoUrls[0])
                                tempList.append(listProduct)
                            } else {
                                let listProduct = ListProduct(id: product.id, businessId: product.businessId, name: product.name, price: product.price, category: "", subcategory: "", photoUrl: product.photoUrls[0])
                                tempList.append(listProduct)
                            }
                            
                        }
                        self.products = tempList
                        self.refreshControl.endRefreshing()
                        self.productCollectionView.reloadData()
                        resolve(true)
                    }
                }
        }
    }
    
    private func loadListCategory() {
        categories = Mapper<Category>().mapArray(JSONfile: "Categories.json")!
        categories = categories.sorted(by: {$0.name < $1.name})
        homeCategoryView.categories = categories
        categoryCollectionView.reloadData()
    }
    
    @IBAction func handleSave(_ sender: Any?) {
        mainTabBar.isHidden = true
        let likeController = SaveController()
        navigationController?.pushViewController(likeController, animated: true)
    }
    
    @IBAction func handleBag(_ sender: Any?) {
        mainTabBar.isHidden = true
        let listController = ListDetailsController()
        navigationController?.pushViewController(listController, animated: true)
    }
    
    func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Home"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel

        let sortButton = UIButton(type: .system)
        sortButton.setImage(UIImage(named: "SortIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        sortButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        sortButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        sortButton.contentHorizontalAlignment = .center
        sortButton.contentVerticalAlignment = .center
        sortButton.contentMode = .scaleAspectFit
        sortButton.backgroundColor = UIColor.clear
        sortButton.layer.cornerRadius = 8
        sortButton.addTarget(self, action: #selector(handleSort(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: sortButton)
        sortButton.snp.makeConstraints{ (make) in
           make.height.width.equalTo(40)
        }
        
        
        if isPersonalAccount {
            let listBarButton = UIBarButtonItem(image: UIImage(named: "BagIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBag(_:)))
            let likeBarButton = UIBarButtonItem(image: UIImage(named: "LikedIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSave(_:)))
            navigationItem.rightBarButtonItems = [listBarButton, likeBarButton]
        }
    }
    
    @IBAction func handleSort(_ sender: Any?) {
        let controller = FilterController()
        controller.mainController = self
        if priceDescending != nil {
            if priceDescending! {
                controller.filterString = "High - Low"
            } else {
                controller.filterString = "Low - High"
            }
        } else {
            if isDescending {
                controller.filterString = "Latest"
            } else {
                controller.filterString = "Earliest"
            }
        }
        controller.filterMinPrice = filterMinPrice
        controller.filterMaxPrice = filterMaxPrice
        customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
    }
    
    @IBAction func handleSelectCategory(_ sender: Any?) {
        let controller = CategoryController()
        controller.previousController = self
        let navController = UINavigationController(rootViewController: controller)
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.barTintColor = UIColor.clear
        self.present(navController, animated: true, completion: nil)
    }
    
    let presenter: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.fluid(percentage: 0.8)
        let center = ModalCenterPosition.bottomCenter
        let presentr = Presentr(presentationType: .custom(width: width, height: height, center: center))
        presentr.roundCorners = true
        presentr.cornerRadius = 10
        presentr.backgroundColor = UIColor.black
        presentr.backgroundOpacity = 0.7
        presentr.transitionType = .coverVertical
        presentr.dismissTransitionType = .coverVertical
        presentr.dismissOnSwipe = true
        presentr.dismissAnimated = true
        presentr.dismissOnSwipeDirection = .default
        return presentr
    }()
    
    private func dispatchLoadController(productId: String) {
        gProductInfoController.productId = productId
        gProductInfoController.isFromSave = false
        gProductInfoController.loadUpdate()
        self.navigationController?.present(gProductNavController, animated: true, completion: nil)
    }
    
    func filterProduct(filter: String, minPrice: Int, maxPrice: Int) {
        if filter == "Earliest" {
            isDescending = false
            priceDescending = nil
        } else  if filter == "Latest"{
            isDescending = true
            priceDescending = nil
        } else if filter == "Low - High" {
            priceDescending = false
        } else if filter == "High - Low" {
            priceDescending = true
        }
        if minPrice >= 0 && maxPrice != 0 {
            filterMinPrice = minPrice
            filterMaxPrice = maxPrice
            minMax = true
        } else if minPrice > 0 && maxPrice == 0 {
            filterMinPrice = minPrice
            filterMaxPrice = maxPrice
            minMax = false
        } else if minPrice == 0 && maxPrice == 0 {
            filterMinPrice = minPrice
            filterMaxPrice = maxPrice
            minMax = nil
        }
        if minMax != nil {
            if minMax! {
                reloadProductByPriceRange()
            } else {
                reloadOnlyWithMin()
            }
        } else if priceDescending == nil {
            loadProducts()
        } else {
            reloadProducts()
        }
    }
    
    private func reloadProducts() {
        filterProductByPrice().then { (check) in
            if (check) {
                self.fetchingStores()
            }
        }
    }
    
    private func filterProductByPrice() -> Promise<Bool>  {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.productRef
                .whereField("isActive", isEqualTo: true)
                .whereField("isBanned", isEqualTo: false)
                .whereField("isAvailable", isEqualTo: true)
                .order(by: "price", descending: self.priceDescending!)
                .limit(to: 30)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        self.refreshControl.endRefreshing()
                        resolve(false)
                    } else {
                        var tempList: [ListProduct] = []
                        for document in querySnapshot!.documents {
                            let product = Mapper<Product>().map(JSONObject: document.data())!
                            let subcategory = gSubcategories.filter({$0.id == product.subcategoryId})
                            if subcategory.count != 0 {
                                let listProduct = ListProduct(id: product.id, businessId: product.businessId, name: product.name, price: product.price, category: subcategory[0].category.name, subcategory: subcategory[0].name, photoUrl: product.photoUrls[0])
                                tempList.append(listProduct)
                            } else {
                                let listProduct = ListProduct(id: product.id, businessId: product.businessId, name: product.name, price: product.price, category: "", subcategory: "", photoUrl: product.photoUrls[0])
                                tempList.append(listProduct)
                            }
                            
                        }
                        self.products = tempList
                        self.refreshControl.endRefreshing()
                        self.productCollectionView.reloadData()
                        resolve(true)
                    }
                }
        }
    }
    
    private func reloadProductByPriceRange() {
        loading.startAnimating()
        filterByPriceRange().then { (check) in
            if (check) {
                self.fetchingStores()
                self.loading.stopAnimating()
            }
        }
    }
    
    private func filterByPriceRange() -> Promise<Bool>  {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.productRef
                .whereField("isActive", isEqualTo: true)
                .whereField("isBanned", isEqualTo: false)
                .whereField("isAvailable", isEqualTo: true)
                .whereField("price", isGreaterThanOrEqualTo: self.filterMinPrice)
                .whereField("price", isLessThanOrEqualTo: self.filterMaxPrice)
                .limit(to: 30)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        self.refreshControl.endRefreshing()
                        resolve(false)
                    } else {
                        var tempList: [ListProduct] = []
                        for document in querySnapshot!.documents {
                            let product = Mapper<Product>().map(JSONObject: document.data())!
                            let subcategory = gSubcategories.filter({$0.id == product.subcategoryId})
                            if subcategory.count != 0 {
                                let listProduct = ListProduct(id: product.id, businessId: product.businessId, name: product.name, price: product.price, category: subcategory[0].category.name, subcategory: subcategory[0].name, photoUrl: product.photoUrls[0])
                                tempList.append(listProduct)
                            } else {
                                let listProduct = ListProduct(id: product.id, businessId: product.businessId, name: product.name, price: product.price, category: "", subcategory: "", photoUrl: product.photoUrls[0])
                                tempList.append(listProduct)
                            }
                            
                        }
                        self.products = tempList
                        self.refreshControl.endRefreshing()
                        self.refreshControl.endRefreshing()
                        self.productCollectionView.reloadData()
                        resolve(true)
                    }
                }
        }
    }
    
    private func reloadOnlyWithMin() {
        loading.startAnimating()
        filterByPriceRangeWithMin().then { (check) in
            if (check) {
                self.fetchingStores()
                self.loading.stopAnimating()
            }
        }
    }
    
    private func filterByPriceRangeWithMin() -> Promise<Bool>  {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.productRef
                .whereField("isActive", isEqualTo: true)
                .whereField("isBanned", isEqualTo: false)
                .whereField("isAvailable", isEqualTo: true)
                .whereField("price", isGreaterThanOrEqualTo: self.filterMinPrice)
                .limit(to: 30)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        self.refreshControl.endRefreshing()
                        resolve(false)
                    } else {
                        var tempList: [ListProduct] = []
                        for document in querySnapshot!.documents {
                            let product = Mapper<Product>().map(JSONObject: document.data())!
                            let subcategory = gSubcategories.filter({$0.id == product.subcategoryId})
                            if subcategory.count != 0 {
                                let listProduct = ListProduct(id: product.id, businessId: product.businessId, name: product.name, price: product.price, category: subcategory[0].category.name, subcategory: subcategory[0].name, photoUrl: product.photoUrls[0])
                                tempList.append(listProduct)
                            } else {
                                let listProduct = ListProduct(id: product.id, businessId: product.businessId, name: product.name, price: product.price, category: "", subcategory: "", photoUrl: product.photoUrls[0])
                                tempList.append(listProduct)
                            }
                            
                        }
                        self.products = tempList
                        self.refreshControl.endRefreshing()
                        self.refreshControl.endRefreshing()
                        self.productCollectionView.reloadData()
                        resolve(true)
                    }
                }
        }
    }
    
    
}

extension HomeController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = width + 60
        return CGSize(width: width, height: height)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeProductCell, for: indexPath) as! HomeProductCell
        cell.product = products[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dispatchLoadController(productId: products[indexPath.item].id)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
            mainTabBar.isHidden = true
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            mainTabBar.isHidden = false
        }
    }
}
