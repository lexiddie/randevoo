//
//  MultipleCategoryView.swift
//  randevoo
//
//  Created by Lex on 5/9/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class MultipleCategoryView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(searchTextField)
        searchTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(35)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
        }
        addSubview(categoryCollectionView)
        categoryCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(searchTextField.snp.bottom)
            make.left.right.lessThanOrEqualTo(self)
            make.bottom.centerX.equalTo(self)
        }
        addSubview(friendlyLabel)
        friendlyLabel.snp.makeConstraints{ (make) in
            make.left.right.equalTo(categoryCollectionView).inset(35)
            make.center.equalTo(categoryCollectionView)
        }
    }
    
    let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    let friendlyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let searchTextField: UITextField = {
        let textField = UITextField(placeholder: "Search subcategories...", placeholderColor: UIColor.randevoo.mainGray, keyboardType: .webSearch)
        textField.font = UIFont(name: "Quicksand-Bold", size: 17)
        textField.textColor = UIColor.randevoo.mainBlack
        textField.backgroundColor = UIColor.randevoo.mainGreyLight
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 0
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.isEnabled = true
        return textField
    }()

}
