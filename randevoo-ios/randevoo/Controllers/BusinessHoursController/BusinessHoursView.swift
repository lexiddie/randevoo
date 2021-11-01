//
//  BusinessHoursView.swift
//  randevoo
//
//  Created by Alexander on 4/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import HorizonCalendar

class BusinessHoursView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(businessHoursCollectionView)
        businessHoursCollectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }

    let businessHoursCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
}
