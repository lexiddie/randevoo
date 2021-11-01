//
//  BizIndividualVIew.swift
//  randevoo
//
//  Created by Xell on 28/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class BizIndividualVIew: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(bizReservationCollectionView)
        bizReservationCollectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        addSubview(friendlyLabel)
        friendlyLabel.snp.makeConstraints{ (make) in
            make.left.right.equalTo(bizReservationCollectionView).inset(30)
            make.center.equalTo(bizReservationCollectionView)
        }
    }
    
    let bizReservationCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.isPagingEnabled = false
        return collectionView
    }()
    
    let friendlyLabel: UILabel = {
        let label = UILabel()
        label.text = "No Reservation is made during this time"
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
}
