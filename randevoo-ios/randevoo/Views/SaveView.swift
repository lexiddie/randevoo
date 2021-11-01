//
//  SaveView.swift
//  randevoo
//
//  Created by Lex on 18/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit

class SaveView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(saveCollectionView)
        saveCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.left.right.lessThanOrEqualTo(self)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self)
        }
        addSubview(friendlyLabel)
        friendlyLabel.snp.makeConstraints{ (make) in
            make.left.right.equalTo(saveCollectionView).inset(30)
            make.center.equalTo(saveCollectionView)
        }
    }
    
    let saveCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
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

}
