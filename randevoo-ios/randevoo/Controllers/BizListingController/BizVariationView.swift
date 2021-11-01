//
//  BizVariationView.swift
//  randevoo
//
//  Created by Lex on 17/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class BizVariationView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(confirmButton)
        confirmButton.snp.makeConstraints{ (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(120)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
        }
        addSubview(variationCollectionView)
        variationCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.centerX.equalTo(self)
            make.bottom.equalTo(confirmButton.snp.top)
        }

        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(4)
            make.width.equalTo(40)
        }
    }
    
    let variationCollectionView: UICollectionView = {
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        collectionView.backgroundColor = UIColor.randevoo.mainLight
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.allowsSelection = true
//        collectionView.alwaysBounceVertical = true
//        collectionView.contentInsetAdjustmentBehavior = .never
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        collectionView.isScrollEnabled = false
//        return collectionView
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.isPagingEnabled = false
        collectionView.isScrollEnabled = true
        return collectionView
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 17)
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.setTitle("Confirm", for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.randevoo.mainColor
        button.addTarget(self, action: #selector(BizVariationController.handleConfirm(_:)), for: .touchUpInside)
        return button
    }()
    
    let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainBlueGrey.withAlphaComponent(0.5)
        view.layer.cornerRadius = 2
        return view
    }()
}
