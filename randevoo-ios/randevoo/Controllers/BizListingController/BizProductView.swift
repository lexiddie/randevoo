//
//  BizProductView.swift
//  randevoo
//
//  Created by Lex on 16/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class BizProductView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(bottomView)
        bottomView.snp.makeConstraints{(make) in
            make.bottom.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.centerX.equalTo(self)
            make.height.equalTo(90)
        }
        addSubview(productCollectionView)
        productCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.centerX.equalTo(self)
            make.bottom.equalTo(bottomView.snp.top)
        }
        bottomView.addSubview(actionButton)
        actionButton.snp.makeConstraints{ (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
        }
    }
    
    let productCollectionView: UICollectionView = {
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
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 17)
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.setTitle("Actions", for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.randevoo.mainColor
        button.addTarget(self, action: #selector(BizProductController.handleAction(_:)), for: .touchUpInside)
        return button
    }()
}
