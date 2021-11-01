//
//  ReservationDetailView.swift
//  randevoo
//
//  Created by Xell on 28/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit
import ImageSlideshow

class ReservationDetailView: UIView {

    let scrollview = UIScrollView()
    let productView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(bottomView)
        bottomView.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.left.lessThanOrEqualTo(self)
            make.right.equalTo(self)
            make.height.equalTo(60)
        }
        addSubview(mainCollectionView)
        mainCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.equalTo(self)
            make.bottom.equalTo(bottomView.snp.top).inset(10)
        }
        bottomView.addSubview(total)
        total.snp.makeConstraints { (make) in
            make.center.equalTo(bottomView)
        }
    }
    
    let mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    let bottomView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let total : UILabel = {
        let label = UILabel()
        label.text = "Total : $12,000"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textAlignment = .right
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
}
