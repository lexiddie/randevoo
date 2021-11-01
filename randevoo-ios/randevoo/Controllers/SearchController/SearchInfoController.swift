//
//  SearchInfoController.swift
//  randevoo
//
//  Created by Xell on 26/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
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
import InstantSearchClient

class SearchSelection: NSObject {
    let label: String
    var isSelected: Bool

    init(label: String, isSelected: Bool) {
        self.label = label
        self.isSelected = isSelected
    }
}

class SearchInfoController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchBarDelegate, SearchSelectionViewDelegate, SearchMapViewDelegate {
    


    private let db = Firestore.firestore()
    private var businessRef: CollectionReference!
    private var productRef: CollectionReference!
    private var bizInfoRef: CollectionReference!
    private let client = Client(appID: "replace-your-api-key", apiKey: "replace-your-api-key")
    private var productIndex: InstantSearchClient.Index!
    private var businessIndex: InstantSearchClient.Index!
    
    let query = Query()
    var searchId = 0
    var displayedSearchId = -1
    var loadedPage: UInt = 0
    var numberPages: UInt = 0
    
    private var searchKey: String = ""
    private var products: [ListProduct] = []
    private var collections: [Collection] = []
    private var stores: [Store] = []
    private var mapProducts: [ListProduct] = []
    private var cachedStoreInfo: [BizInfo] = []
    
    private var searchSelections: [SearchSelection] = [SearchSelection(label: "Products", isSelected: true),
                                                       SearchSelection(label: "Stores", isSelected: false),
                                                       SearchSelection(label: "Maps", isSelected: false)]
    
    var searchMapFlexCell = "searchMapFlexCell"
    var productFlexCell = "productFlexCell"
    var productCollectionCell = "productCollectionCell"
    var storeFlexCell = "storeFlexCell"

    private var selectSearch = 0
    private var infoCollectionView: UICollectionView!
    private var friendlyLabel: UILabel!
    
    private var isFirst: Bool = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.isUserInteractionEnabled = true
        return searchBar
    }()
    
    private lazy var searchSelectionView: SearchSelectionView = {
        let view = SearchSelectionView()
        view.searchSelections = self.searchSelections
        view.delegate = self
        return view
    }()
    
    private lazy var searchMapView: SearchMapView = {
        let view = SearchMapView()
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        setupNavItems()
        initialCollectionView()
        initiateFirestore()
        initiateSearchAlgolia()
        
        isFirst = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
        searchSelectionView.animateBar(indexPath: selectSearch, duration: 0.4)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("GPS is closed")
        searchMapView.locationManager.stopUpdatingLocation()
    }
    
    func loadUpdate() {
        if isFirst {
            searchKey = ""
            searchBar.text = ""
            cleanSearch()
            didSelectSearch(selectIndex: 0)
            searchSelectionView.selectionCollectionView.reloadData()
        }
    }
    
    private func initialView() {
        let view = SearchInfoView(frame: self.view.frame)
        self.infoCollectionView = view.infoCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.view = view
        self.view.addSubview(searchSelectionView)
        searchSelectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(40)
            make.centerX.equalTo(self.view)
            make.left.right.lessThanOrEqualTo(self.view)
        }
        self.view.addSubview(searchMapView)
        searchMapView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(40)
            make.centerX.equalTo(self.view)
            make.left.right.lessThanOrEqualTo(self.view)
            make.bottom.equalTo(self.view)
        }
        self.hideKeyboardWhenTappedAround()
    }
    
    private func initialCollectionView() {
        infoCollectionView.delegate = self
        infoCollectionView.dataSource = self
        infoCollectionView.register(ProductFlexCell.self, forCellWithReuseIdentifier: productFlexCell)
        infoCollectionView.register(ProductCollectionCell.self, forCellWithReuseIdentifier: productCollectionCell)
        infoCollectionView.register(StoreFlexCell.self, forCellWithReuseIdentifier: storeFlexCell)
        infoCollectionView.keyboardDismissMode = .onDrag
        loadFriendlyLabel()
    }
    
    private func initiateFirestore() {
        businessRef = db.collection("businesses")
        productRef = db.collection("products")
        bizInfoRef = db.collection("bizInfos")
    }
    
    private func initiateSearchAlgolia() {
        productIndex = client.index(withName: "prod_products")
        businessIndex = client.index(withName: "prod_businesses")
        query.hitsPerPage = 15
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("On Type Output \(String(searchText))")
        searchKey = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        query.query = searchKey
        if searchText.isEmpty || searchText == "" {
            cleanSearch()
            print("It's empty, type")
        }
        else {
            fetchSelection()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        print("On Search Output \(String(searchText))")
        searchBar.endEditing(true)
        searchKey = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        query.query = searchKey
        if searchText.isEmpty || searchText == "" {
            cleanSearch()
            print("It's empty, search")
        }
    }
    
    func loadMore() {
        if loadedPage + 1 >= numberPages {
            return
        }
        let nextQuery = Query(copy: query)
        nextQuery.page = loadedPage + 1
        
        productIndex.search(nextQuery, completionHandler: { (content , error) in
            
        })
    }
    
    private func cleanSearch() {
        products = []
        stores = []
        mapProducts = []
        searchMapView.products = []
        searchMapView.productCollectionView.reloadData()
        searchMapView.isHidden = true
        infoCollectionView.reloadData()
        loadFriendlyLabel()
    }
    
    private func fetchSelection() {
        searchMapView.isHidden = true
        if searchKey.isEmpty || searchKey == "" {
            print("Search Key is empty cannot be query!")
            cleanSearch()
            return
        } else if selectSearch == 0 {
            productIndex.search(query, completionHandler: { (content, error) in
                if let data = content!["hits"] {
                    let currents = Mapper<ProductDto>().mapArray(JSONObject: data)!
                    self.searchProducts(currents: currents)
                }
            })
        } else if selectSearch == 1 {
            businessIndex.search(query, completionHandler: { (content, error) in
                if let data = content!["hits"] {
                    let currents = Mapper<BusinessDto>().mapArray(JSONObject: data)!
                    self.searchBusinesses(currents: currents)
                }
            })
        } else if selectSearch == 2 {
            searchMapView.isHidden = false
            productIndex.search(query, completionHandler: { (content, error) in
                if let data = content!["hits"] {
                    let currents = Mapper<ProductDto>().mapArray(JSONObject: data)!
                    self.searchMapProducts(currents: currents)
                }
            })
        }
    }
    
    private func searchProducts(currents: [ProductDto]) {
        if !searchKey.isEmpty || searchKey != "" {
            var tempList: [ListProduct] = []
            for i in currents {
                let current = ListProduct(id: i.id, businessId: i.businessId, name: i.name, price: i.price, photoUrl: i.photoUrl)
                tempList.append(current)
            }
            products = tempList
            infoCollectionView.reloadData()
            loadFriendlyLabel()
        }
    }
    
    private func searchBusinesses(currents: [BusinessDto]) {
        if !searchKey.isEmpty || searchKey != "" {
            var tempList: [Store] = []
            for i in currents {
                let current = Store(id: i.id, name: i.name, username: i.username, location: i.location, type: i.type, profileUrl: i.profileUrl)
                tempList.append(current)
            }
            stores = tempList
            infoCollectionView.reloadData()
            loadFriendlyLabel()
        }
    }
    
    private func searchMapProducts(currents: [ProductDto]) {
        if !searchKey.isEmpty || searchKey != "" {
            var tempList: [ListProduct] = []
            for i in currents {
                let current = ListProduct(id: i.id, businessId: i.businessId, name: i.name, price: i.price, photoUrl: i.photoUrl)
                tempList.append(current)
            }
            let storeIds = getStoreIds(products: tempList)
            fetchGeoPointProducts(storeIds: storeIds)
            mapProducts = tempList
            searchMapView.products = mapProducts
            searchMapView.googleMapView.clear()
            searchMapView.productCollectionView.reloadData()
            searchMapView.loadFriendlyLabel()
        }
    }
    
    private func getStoreIds(products: [ListProduct]) -> [String] {
        var tempList: [String] = []
        for i in products {
            if !tempList.contains(where: {$0 == i.businessId}){
                tempList.append(i.businessId)
            }
        }
        return tempList
    }
    
    private func fetchGeoPointProducts(storeIds: [String]) {
        cachedStoreInfo.removeAll()
        for (_, element) in storeIds.enumerated() {
            bizInfoRef.whereField("businessId", isEqualTo: element).limit(to: 1).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting bizInfo documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let result = Mapper<BizInfo>().map(JSONObject: document.data())!
                        self.cachedStoreInfo.append(result)
                    }
                    
                    if self.cachedStoreInfo.count == storeIds.count {
                        self.manipulateGeoPoints()
                    }
                }
            }
        }
        
    }
    
    private func manipulateGeoPoints() {
        for i in mapProducts {
            if let info = cachedStoreInfo.first(where: {$0.businessId == i.businessId}) {
                i.bizGeoPoint = info.geoPoint
            }
        }
        
        let infoJson = Mapper().toJSONString(mapProducts, prettyPrint: true)!
        print("mapProducts: \(infoJson)")
        
        searchMapView.products = mapProducts
        searchMapView.productCollectionView.reloadData()
        searchMapView.loadFriendlyLabel()
    }

    private func loadFriendlyLabel() {
        if selectSearch == 0 && products.count == 0 {
            friendlyLabel.text = "No products to show😴"
        } else if selectSearch == 1 && stores.count == 0 {
            friendlyLabel.text = "No stores to show😴"
        } else if selectSearch == 2 && mapProducts.count == 0 {
            friendlyLabel.text = "No products via map😴"
        } else {
            friendlyLabel.text = nil
        }
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    private func setupNavItems() {
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDismiss(_:)))
        doneBarButton.tintColor = UIColor.randevoo.mainBlack
        navigationItem.rightBarButtonItem = doneBarButton
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        UIView.animate(withDuration: 0.7, animations: {
            self.searchBar.snp.makeConstraints{ (make) in
                make.height.equalTo(40)
                make.width.equalTo(self.view.frame.width - 90)
            }
        }, completion: nil)

        searchBar.delegate = self

        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func dispatchLoadController(productId: String) {
        gProductInfoController.productId = productId
        gProductInfoController.isFromSave = false
        gProductInfoController.loadUpdate()
        self.navigationController?.present(gProductNavController, animated: true, completion: nil)
    }
    
    func didSelectOnMap(indexProduct: Int) {
        dispatchLoadController(productId: mapProducts[indexProduct].id)
    }

}

extension SearchInfoController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectSearch == 0 {
            let width = (view.frame.width - 2) / 2
            return CGSize(width: width, height: width)
        } else if selectSearch == 1 {
            let width = view.frame.width
            return CGSize(width: width, height: 60)
        } else {
            let width = view.frame.width
            return CGSize(width: width, height: width)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if selectSearch == 1 {
            return 15
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if selectSearch == 1 {
            return 15
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectSearch == 0 {
            return products.count
        } else if selectSearch == 1 {
            return stores.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if selectSearch == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: storeFlexCell, for: indexPath) as! StoreFlexCell
            cell.store = stores[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productFlexCell, for: indexPath) as! ProductFlexCell
            cell.product = products[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectSearch == 0 {
            dispatchLoadController(productId: products[indexPath.item].id)
        } else if selectSearch == 1 {
            let controller = StoreController()
            controller.storeId = stores[indexPath.item].id
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didSelectSearch(selectIndex: Int) {
        selectSearch = selectIndex
        for (index, element) in searchSelections.enumerated() {
            if index == selectIndex {
                element.isSelected = true
            } else {
                element.isSelected = false
            }
        }
        fetchSelection()
    }
}
