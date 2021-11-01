//
//  SearchController.swift
//  randevoo
//
//  Created by Lex on 15/8/20.
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

class SearchController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchBarDelegate {
    
    var mainTabBar: UITabBar!
    let searchCollectionCell = "searchCollectionCell"
    
    private var colors: [Color] = []
    private var searchCollectionView: UICollectionView!
    private var friendlyLabel: UILabel!
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.isUserInteractionEnabled = false
        searchBar.backgroundColor = UIColor.clear
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        setupNavItems()
        initialCollectView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let mainTabBarController = self.tabBarController as! MainTabBarController
        mainTabBar = mainTabBarController.tabBar
        mainTabBar.isHidden = false
        
        searchBar.text = ""
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.isOpaque = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func fetchColors() {
        colors = Mapper<Color>().mapArray(JSONfile: "Colors.json")!
        colors = colors.sorted(by: {$0.name < $1.name})
        searchCollectionView.reloadData()
    }
    
    private func initialView() {
        let view = SearchView(frame: self.view.frame)
        self.searchCollectionView = view.searchCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.view = view
        self.hideKeyboardWhenTappedAround()
    }
    
    private func initialCollectView() {
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.register(SearchCollectionCell.self, forCellWithReuseIdentifier: searchCollectionCell)
        loadFriendlyLabel()
    }
    
    private func loadFriendlyLabel() {
        if colors.count == 0 {
            friendlyLabel.text = "Enter a few words \nto search on Randevoo🥺"
        } else {
            friendlyLabel.text = nil
        }
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
    
    private func setupNavItems() {
        if isPersonalAccount {
            let bagBarButton = UIBarButtonItem(image: UIImage(named: "BagIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBag(_:)))
            let saveBarButton = UIBarButtonItem(image: UIImage(named: "LikedIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSave(_:)))
            navigationItem.rightBarButtonItems = [bagBarButton, saveBarButton]
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        searchBar.snp.makeConstraints{ (make) in
            make.height.equalTo(40)
            if isPersonalAccount {
                make.width.equalTo(self.view.frame.width - 130)
            } else {
                make.width.equalTo(self.view.frame.width - 40)
            }
        }
        searchBar.delegate = self
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        gSearchInfoController.loadUpdate()
        self.navigationController?.present(gSearchNavController, animated: true, completion: nil)
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

extension SearchController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 2
        return CGSize(width: width - 15, height: width / 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: searchCollectionCell, for: indexPath) as! SearchCollectionCell
        cell.color = colors[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Clicked", indexPath.item)
    }
}
