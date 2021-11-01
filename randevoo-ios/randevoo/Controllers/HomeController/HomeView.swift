//
//  HomeView.swift
//  randevoo
//
//  Created by Lex on 18/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit
import NVActivityIndicatorView

class HomeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(productCollectionView)
        productCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.centerX.bottom.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
        }
        addSubview(friendlyLabel)
        friendlyLabel.snp.makeConstraints{ (make) in
            make.left.right.equalTo(productCollectionView).inset(35)
            make.center.equalTo(productCollectionView)
        }
        productCollectionView.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.center.equalTo(productCollectionView)
        }
//        addSubview(locationButton)
//        locationButton.snp.makeConstraints { (make) in
//            make.top.equalTo(self.safeAreaLayoutGuide).inset(50)
//            make.centerX.equalTo(self)
//            make.height.equalTo(30)
//            make.left.right.lessThanOrEqualTo(self)
//        }
//        locationButton.addSubview(gpsImageView)
//        gpsImageView.snp.makeConstraints { (make) in
//            make.centerY.equalTo(locationButton)
//            make.height.width.equalTo(25)
//            make.left.lessThanOrEqualTo(locationButton).inset(10)
//        }
    }
    
    let productCollectionView: UICollectionView = {
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
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let loading: NVActivityIndicatorView = {
        let loading = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: UIColor.randevoo.mainColor, padding: 0)
        return loading
    }()
    
//    let locationButton: UIButton = {
//        let button = UIButton(type: .custom)
//        button.backgroundColor = UIColor.randevoo.mainLight
//        button.contentHorizontalAlignment = .left
//        button.contentVerticalAlignment = .center
//        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 45, bottom: 0, right: 10)
//        button.setTitle("Samut Prakan | Thailand", for: .normal)
//        button.setTitleColor(UIColor.randevoo.mainBlack, for: .normal)
//        button.titleLabel?.font = UIFont(name: "Quicksand-Regular", size: 15)
//        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
//        button.addTarget(self, action: #selector(HomeController.handleLocation(_:)), for: .touchUpInside)
//        return button
//    }()
//    
//    let gpsImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = #imageLiteral(resourceName: "LocationGPS").withRenderingMode(.alwaysOriginal)
//        return imageView
//    }()
}
