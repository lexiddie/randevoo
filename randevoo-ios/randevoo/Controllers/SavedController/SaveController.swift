//
//  SaveController.swift
//  randevoo
//
//  Created by Lex on 18/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import ObjectMapper
import Alamofire
import AlamofireImage
import Cache
import SnapKit

class SaveController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let defaults = UserDefaults.standard
    let db = Firestore.firestore()
    var user: User!
    let productCell = "productCell"
    var listProducts: [ListProduct] = []
    var refreshControl = UIRefreshControl()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        table.allowsSelection = true
        return table
    }()
    
    let friendlyLabel: UILabel = {
        let label = UILabel()
        label.text = "Wow, such empty"
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        setupTableView()
        setupTitleNavItem()
//        handleLoadListProduct()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handleLoadListProduct()
    }
    
    private func initialView() {
        let view = SaveView(frame: self.view.frame)
        self.view = view
    }
    
    private func setupTableView() {
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProductCell.self, forCellReuseIdentifier: productCell)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
        tableView.reloadData()
        tableView.addSubview(friendlyLabel)
        friendlyLabel.snp.makeConstraints{ (make) in
            make.left.right.equalTo(tableView).inset(35)
            make.center.equalTo(tableView)
        }
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    private func loadFriendlyLabel() {
        if listProducts.count == 0 {
            friendlyLabel.text = "Wow, such empty"
        } else {
            friendlyLabel.text = nil
        }
    }
    
    @IBAction func refreshList(_ sender: Any?) {
        handleLoadListProduct()
    }
    
    private func setupTitleNavItem() {
        let titleLabel = UILabel()
        titleLabel.text = "Saved"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 275
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: productCell, for: indexPath) as! ProductCell
        // print("Checking the productImageUrl in list \(String(listProducts[indexPath.item].productImageUrl))")
        // cell.productImageView.af.setImage(withURL: URL(string: listProducts[indexPath.item].productImageUrl)!)
        // if listProducts[indexPath.item].sellerImageUrl != "" {
        //     cell.sellerProfileImageView.af.setImage(withURL: URL(string: listProducts[indexPath.item].sellerImageUrl)!)
        // }

        cell.productImageView.loadCacheImage(urlString: listProducts[indexPath.item].productImageUrl)
        cell.sellerProfileImageView.loadCacheImage(urlString: listProducts[indexPath.item].sellerImageUrl)

        cell.productNameLabel.text = listProducts[indexPath.item].name
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let productPriceFormat = numberFormatter.string(from: NSNumber(value: listProducts[indexPath.item].price))
        cell.productPriceLabel.text = "\(listProducts[indexPath.item].currency!) \(String(productPriceFormat!))"
        cell.selectionStyle = UITableViewCell.SelectionStyle.gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let checkProductController = CheckProductController()
        checkProductController.productId = listProducts[indexPath.item].id
        checkProductController.user = user
        let navController = UINavigationController(rootViewController: checkProductController)
//        navigationController.modalPresentationStyle = .fullScreen
        tableView.deselectRow(at: indexPath, animated: true)
        self.present(navigationController, animated: true, completion: nil)
    }
}
