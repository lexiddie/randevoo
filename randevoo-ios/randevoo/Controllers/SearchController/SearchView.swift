//
//  SearchView.swift
//  randevoo
//
//  Created by Lex on 15/8/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit

class SearchView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(searchCollectionView)
        searchCollectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        addSubview(friendlyLabel)
        friendlyLabel.snp.makeConstraints{ (make) in
            make.left.right.equalTo(searchCollectionView).inset(30)
            make.center.equalTo(searchCollectionView)
        }
//        addSubview(searchGifImageView)
//        searchGifImageView.snp.makeConstraints{ (make) in
//            make.width.height.equalTo(300)
//            make.centerX.equalTo(searchCollectionView)
//            make.bottom.equalTo(friendlyLabel.snp.top).offset(50)
//        }
    }
    
    let searchCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
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
    
//    let searchGifImageView: UIImageView = {
//        let imageView = UIImageView(image: UIImage.gifImageWithName("search"))
//        imageView.layer.borderColor = UIColor.clear.cgColor
//        imageView.backgroundColor = UIColor.clear
//        imageView.contentMode = .scaleAspectFit
//        imageView.clipsToBounds = true
//        return imageView
//    }()
}
