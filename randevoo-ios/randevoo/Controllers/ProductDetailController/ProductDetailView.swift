//
//  ProductDetailView.swift
//  randevoo
//
//  Created by Xell on 10/11/2563 BE.
//  Copyright © 2563 Lex. All rights reserved.
//

import UIKit
import SnapKit

class ProductDetailView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        backgroundColor = UIColor.white
        addSubview(bottomView)
        bottomView.snp.makeConstraints{(make) in
            make.bottom.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.centerX.equalTo(self)
            make.height.equalTo(100)
        }
        bottomView.addSubview(addToBagButton)
        addToBagButton.snp.makeConstraints{ (make) in
            make.top.equalTo(bottomView).inset(10)
            make.left.equalTo(bottomView).inset(20)
            make.width.height.equalTo(40)
        }
        bottomView.addSubview(viewBagButton)
        viewBagButton.snp.makeConstraints{ (make) in
            make.top.equalTo(bottomView).inset(10)
            make.left.equalTo(addToBagButton.snp.right).offset(20)
            make.width.height.equalTo(40)
        }
        addSubview(productDetailCollectionView)
        productDetailCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.centerX.equalTo(self)
            make.bottom.equalTo(bottomView.snp.top)
        }
    }
    
    let productDetailCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let addToBagButton: UIButton = {
        let button = UIButton(type: .system)
        let addImg = UIImage(named: "AddingIcon")
        button.setImage(addImg, for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = UIColor.randevoo.mainBlack
        button.addTarget(self, action: #selector(ProductDetailController.handleAddToBag(_:)), for: .touchUpInside)
        return button
    }()
    
    let viewBagButton: UIButton = {
        let button = UIButton(type: .system)
        let listImg = UIImage(named: "BagIcon")
        button.setImage(listImg, for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = UIColor.randevoo.mainBlack
        button.addTarget(self, action:#selector(ProductDetailController.handleViewBag(_:)), for: .touchUpInside)
        return button
    }()

}

