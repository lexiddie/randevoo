//
//  CategoryController.swift
//  collexapp
//
//  Created by Lex on 23/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper

class CategoryController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CategorytSelectionCellDelegate {

    var isListing: Bool = false
    
    var previousController: UIViewController!
    let categorySelectionCell = "categorySelectionCell"
    let subcategoryCell = "subcategoryCell"
    
//    var categories: [Category] = [Category(name: "Men", isSelected: true),
//                                  Category(name: "Women"),
//                                  Category(name: "Services")]
    
    var categories: [Category] = [Category(name: "Men", isSelected: true),
                                  Category(name: "Women")]
    
    var subcategories: [Subcategory] = []
    var tempSubcategories: [Subcategory] = []
    
    private var selectCategory = 0
    private var categoryCollectionView: UICollectionView!
    private var friendlyLabel: UILabel!
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialCollectionView()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func initialView() {
        let view = CategoryView(frame: self.view.frame)
        self.categoryCollectionView = view.categoryCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.view = view
    }
    
    private func loadData() {
        subcategories = gSubcategories
        fetchCategories()
        fetchSelection()
    }
    
    private func fetchCategories() {
        for i in categories {
            if let category = gCategories.first(where: {$0.name == i.name}) {
                i.id = category.id
            }
        }
    }
    
    private func fetchSelection() {
        for (index, element) in categories.enumerated() {
            if index == selectCategory {
                element.isSelected = true
            } else {
                element.isSelected = false
            }
        }
        let selectId = categories[selectCategory].id
        tempSubcategories = fetchSubcategories(categoryId: selectId!)
        categoryCollectionView.reloadData()
    }
    
    private func fetchSubcategories(categoryId: String) -> [Subcategory] {
        var tempList: [Subcategory] = []
        for i in subcategories {
            if i.category.id == categoryId {
                tempList.append(i)
            }
        }
        return tempList
    }
    
    private func initialCollectionView() {
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(CategorySelectionCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: categorySelectionCell)
        categoryCollectionView.register(SubcategoryCell.self, forCellWithReuseIdentifier: subcategoryCell)
        categoryCollectionView.keyboardDismissMode = .onDrag
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: UIControl.Event.valueChanged)
        categoryCollectionView.addSubview(refreshControl)
    }

    
    @IBAction func refreshList(_ sender: Any?) {

    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Category"
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


extension CategoryController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: categorySelectionCell, for: indexPath) as! CategorySelectionCell
        header.categories = categories
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 40, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tempSubcategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: subcategoryCell, for: indexPath) as! SubcategoryCell
        cell.subcategory = tempSubcategories[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isListing, let controller = previousController as? ListingController {
            if controller.selectedSubcategory?.id != tempSubcategories[indexPath.item].id {
                controller.variants.removeAll()
                controller.listingCollectionView.reloadData()
            }
            controller.selectedSubcategory = tempSubcategories[indexPath.item]
            controller.checkingResult()
            controller.listingCollectionView.reloadData()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func didSelectCategory(selectIndex: Int) {
        selectCategory = selectIndex
        fetchSelection()
    }
    
}
