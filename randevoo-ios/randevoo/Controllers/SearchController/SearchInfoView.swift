//
//  SearchInfoView.swift
//  randevoo
//
//  Created by Lex on 19/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class SearchInfoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(infoCollectionView)
        infoCollectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        addSubview(friendlyLabel)
        friendlyLabel.snp.makeConstraints{ (make) in
            make.left.right.equalTo(infoCollectionView).inset(30)
            make.center.equalTo(infoCollectionView)
        }
    }

    let infoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
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
