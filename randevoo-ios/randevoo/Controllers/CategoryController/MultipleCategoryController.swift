//
//  MultipleCategoryController.swift
//  randevoo
//
//  Created by Lex on 5/9/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper

class MultipleCategoryController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    var previousController: UIViewController!
    let multipleCategoryCell = "categoryCell"
    let multipleSubcategoryCell = "multipleSubcategoryCell"
    
    var categories = [Category]()
    var selectedCategories: [Category] = []
    
    private var selectCategory = 0
    private var searchTextField: UITextField!
    private var categoryCollectionView: UICollectionView!
    private var friendlyLabel: UILabel!
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        initialCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    
    private func initialView() {
        let view = MultipleCategoryView(frame: self.view.frame)
        self.searchTextField = view.searchTextField
        self.categoryCollectionView = view.categoryCollectionView
        self.friendlyLabel  = view.friendlyLabel
        self.view = view
    }
    
    private func initialCollectionView() {
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(MultipleCategoryCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: multipleCategoryCell)
        categoryCollectionView.register(MultipleSubcategoryCell.self, forCellWithReuseIdentifier: multipleSubcategoryCell)
        categoryCollectionView.keyboardDismissMode = .onDrag
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: UIControl.Event.valueChanged)
        categoryCollectionView.addSubview(refreshControl)
    }
    
    @IBAction func refreshList(_ sender: Any?) {

    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MultipleCategoryController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: multipleCategoryCell, for: indexPath) as! MultipleCategoryCell
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: multipleSubcategoryCell, for: indexPath) as! MultipleSubcategoryCell
        return cell
    }
}
