//
//  BizListingController.swift
//  randevoo
//
//  Created by Lex on 1/3/21.
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
import ImageSlideshow
import Cache
import SnapKit
import Hydra

class BizListingController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let db = Firestore.firestore()
    private var productRef: CollectionReference!
    
    private var products: [Product] = []
    
    private let bizListingCell = "bizListingCell"
    private var friendlyLabel: UILabel!
    private var productCollectionView: UICollectionView!
    
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

        loadProducts()
        
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func initialView() {
        let view = BizListingView(frame: self.view.frame)
        self.productCollectionView = view.productCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.view = view
    }
    
    private func initiateFirestore() {
        productRef = db.collection("products")
    }
    
    private func initialCollectionView() {
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        productCollectionView.register(BizListingCell.self, forCellWithReuseIdentifier: bizListingCell)
    }
    
    private func loadFriendlyLabel() {
        if products.count == 0 {
            friendlyLabel.text = "No have not listed any products!😘"
        } else {
            friendlyLabel.text = nil
        }
    }
    
    private func loadProducts() {
        guard let business = businessAccount else { return }
        loadFriendlyLabel()
        fetchProducts(businessId: business.id).then { (_) in
            self.loadFriendlyLabel()
        }
    }
    
    private func fetchProducts(businessId: String) -> Promise<Bool>  {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.productRef
                .whereField("isBanned", isEqualTo: false)
                .whereField("isActive", isEqualTo: true)
                .whereField("businessId", isEqualTo: businessId)
                .order(by: "createdAt", descending: true)
                .limit(to: 100)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        resolve(false)
                    } else {
                        var tempList: [Product] = []
                        for document in querySnapshot!.documents {
                            let product = Mapper<Product>().map(JSONObject: document.data())!
                            tempList.append(product)
                          
                        }
                        self.products = tempList
                        self.productCollectionView.reloadData()
                        resolve(true)
                    }
                }
        }
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Manage Products"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel

        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(named: "DismissIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        dismissButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentHorizontalAlignment = .center
        dismissButton.contentVerticalAlignment = .center
        dismissButton.contentMode = .scaleAspectFit
        dismissButton.backgroundColor = UIColor.clear
        dismissButton.layer.cornerRadius = 8
        dismissButton.addTarget(self, action: #selector(handleDismiss(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        dismissButton.snp.makeConstraints{ (make) in
           make.height.width.equalTo(40)
        }

    }
}

extension BizListingController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = width
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bizListingCell, for: indexPath) as! BizListingCell
        cell.product = products[indexPath.item].copy()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = BizProductController()
        controller.product = products[indexPath.item]
        navigationController?.pushViewController(controller, animated: true)
    }
}
