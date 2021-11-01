//
//  PersonalView.swift
//  randevoo
//
//  Created by Lex on 5/12/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class PersonalView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.white
        addSubview(personalCollectionView)
        personalCollectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }

    let personalCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.isPagingEnabled = false
        return collectionView
    }()

}
