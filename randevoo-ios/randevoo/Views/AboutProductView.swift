//
//  AboutProductView.swift
//  randevoo
//
//  Created by Xell on 9/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class AboutProductView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(addButton)
        addButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).inset(70)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.height.equalTo(50)
            make.width.equalTo(self.frame.width - 20)
        }
        addSubview(mainCollectionView)
        mainCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.equalTo(self)
            make.bottom.equalTo(addButton.snp.top)
        }
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(4)
            make.width.equalTo(40)
        }
    }
    
    let mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.randevoo.mainColor
        button.layer.cornerRadius = 5
        button.setTitle("Done", for: .normal)
        button.tintColor = UIColor.white
        button.titleLabel?.font =  UIFont(name: "Quicksand-Meduim", size: 20)
        button.layer.borderColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.5).cgColor
        button.addTarget(self, action: #selector(AboutProductViewController.handleDismiss(_:)), for: .touchUpInside)
        return button
    }()
    
    let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainBlueGrey.withAlphaComponent(0.5)
        view.layer.cornerRadius = 2
        return view
    }()

}
