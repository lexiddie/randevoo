//
//  SaveController.swift
//  randevoo
//
//  Created by Xell on 14/11/2563 BE.
//  Copyright © 2563 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import ObjectMapper

class SaveController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let db = Firestore.firestore()
    var products: [Product] = []
    var tempProd: [Product] = []
    
    private let productGridCell = "productGridCell"
    private var saveCollectionView: UICollectionView!
    private var friendlyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchSaves()
    }
    
    private func initialView() {
        let view = SaveView(frame: self.view.frame)
        self.saveCollectionView = view.saveCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.view = view
    }
    
    func fetchSaves() {
        guard let personal = personalAccount else { return }
        fetchSaves(personal: personal)
        loadFriendlyLabel()
    }
    
    private func loadFriendlyLabel() {
        if products.count == 0 {
            friendlyLabel.text = "No save is found💛"
        } else {
            friendlyLabel.text = nil
        }
    }
    
    private func initialCollectionView() {
        saveCollectionView.delegate = self
        saveCollectionView.dataSource = self
        saveCollectionView.register(ProductGridCell.self, forCellWithReuseIdentifier: productGridCell)
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Saved"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "ArrowLeft")!.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentHorizontalAlignment = .center
        backButton.contentVerticalAlignment = .center
        backButton.contentMode = .scaleAspectFit
        backButton.backgroundColor = UIColor.clear
        backButton.layer.cornerRadius = 8
        backButton.addTarget(self, action: #selector(handleBack(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.snp.makeConstraints{ (make) in
           make.height.width.equalTo(40)
        }
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func fetchSaves(personal: PersonalAccount) {
        tempProd.removeAll()
        saveCollectionView.reloadData()
        let productRef = self.db.collection("products")
        let saveRef = self.db.collection("saves")
        if let saves: [Save] = FCache.get("saves"), !FCache.isExpired("saves") {
            for save in saves {
                productRef.document(save.productId).getDocument() { [self] (document, error) in
                    if let document = document, document.exists {
                        let result = Mapper<Product>().map(JSONObject: document.data())
                        if !self.tempProd.contains(where: {$0.id == result?.id}){
                            self.tempProd.append(result!)
                        }
                    }
                    if tempProd.count != products.count {
                        products = tempProd
                        saveCollectionView.reloadData()
                        self.loadFriendlyLabel()
                    }
                }
            }
            saveCollectionView.reloadData()
        } else {
            saveRef.whereField("userId", isEqualTo: personalAccount?.id).getDocuments() {[self] (querySnapshot, err) in
                if err != nil {
                    print("Failed to retrieve saves")
                } else {
                    for document in querySnapshot!.documents {
                        let result = Mapper<Save>().map(JSONObject: document.data())
                        productRef.whereField("id", isEqualTo: result?.id).getDocuments(){ [self] (querySnapshot, err) in
                            if err != nil {
                                print("Faild to retrieve saves")
                            } else {
                                for document in querySnapshot!.documents {
                                    let result = Mapper<Product>().map(JSONObject: document.data())
                                    if !self.tempProd.contains(where: {$0.id == result?.id}){
                                        self.tempProd.append(result!)
                                    }
                                }
                                if tempProd.count != products.count {
                                    products = tempProd
                                    saveCollectionView.reloadData()
                                    self.loadFriendlyLabel()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func dispatchLoadController(productId: String) {
        gProductInfoController.productId = productId
        gProductInfoController.isFromSave = true
        gProductInfoController.likeController = self
        gProductInfoController.loadUpdate()
        self.navigationController?.present(gProductNavController, animated: true, completion: nil)
    }
    
}

extension SaveController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 2
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productGridCell, for: indexPath) as! ProductGridCell
        cell.productImageView.loadCacheImage(urlString: products[indexPath.row].photoUrls[0])
        cell.priceLabel.text = products[indexPath.row].name
        if !products[indexPath.row].isActive || products[indexPath.row].available < 0 || products[indexPath.row].isBanned {
            cell.isBannedLabel.isHidden = false
            cell.background.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            cell.isBannedLabel.text = "Not Available!"
            cell.isBannedLabel.textColor = UIColor.red
        } else {
            cell.background.backgroundColor = .clear
            cell.isBannedLabel.isHidden = true
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dispatchLoadController(productId: products[indexPath.item].id)
    }
}

