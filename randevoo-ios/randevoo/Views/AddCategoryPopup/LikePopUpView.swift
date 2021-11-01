//
//  LikePopUpView.swift
//  randevoo
//
//  Created by Xell on 4/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class LikePopUpView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.centerX.equalTo(self)
        }
        addSubview(addNewCategory)
        addNewCategory.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.right.equalTo(self).inset(20)
            make.width.height.equalTo(25)
        }
        addSubview(listCollection)
        listCollection.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.height.equalTo(80)
            make.centerY.equalTo(self)
        }
    }
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ADD TO LIKE"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let addNewCategory: UIButton = {
        let button = UIButton(type: .system)
        let addImg = UIImage(named: "AddingIcon")
        button.setImage(addImg, for: .normal)
        button.tintColor = UIColor.randevoo.mainBlack
        //        button.addTarget(self, action: #selector(viewAddNew(_:)), for: .touchUpInside)
        return button
    }()
    
    let listCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    
}
