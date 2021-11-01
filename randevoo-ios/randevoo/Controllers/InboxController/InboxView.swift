//
//  InboxView.swift
//  randevoo
//
//  Created by Lex on 10/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class InboxView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(inboxCollectionView)
        inboxCollectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        addSubview(friendlyLabel)
        friendlyLabel.snp.makeConstraints{ (make) in
            make.left.right.equalTo(inboxCollectionView).inset(30)
            make.center.equalTo(inboxCollectionView)
        }
    }
    
    let inboxCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 10, bottom: 40, right: 10)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 10, bottom: 40, right: 10)
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
