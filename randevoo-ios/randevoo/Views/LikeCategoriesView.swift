//
//  LikeCategoriesView.swift
//  randevoo
//
//  Created by Xell on 14/11/2563 BE.
//  Copyright © 2563 Lex. All rights reserved.
//

import UIKit

class LikeCategoriesView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(likedCategoriesCollectionView)
        likedCategoriesCollectionView.snp.makeConstraints{ (make) in
            make.top.left.bottom.equalTo(self).offset(10)
            make.right.equalTo(self).inset(10)
        }
        addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
    
    let likedCategoriesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.isPagingEnabled = false
        return collectionView
    }()
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Like List is Empty"
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
}
