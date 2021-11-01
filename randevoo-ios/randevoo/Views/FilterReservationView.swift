//
//  FilterReservationView.swift
//  randevoo
//
//  Created by Xell on 28/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class FilterReservationView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.white
        let heightOfBottomView = (self.frame.height / 5) - 65
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(4)
            make.width.equalTo(40)
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(40)
            make.left.equalTo(self).offset(10)
        }
        addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.left.right.equalTo(self)
            make.height.equalTo(50)
        }
        bottomView.addSubview(applyButton)
        applyButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(bottomView)
            make.top.equalTo(bottomView).inset(10)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(mainCollectionView)
        mainCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.equalTo(bottomView.snp.top).inset(10)
            make.left.right.lessThanOrEqualTo(self).offset(10)
            make.centerX.equalTo(self)
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
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Filter & Sort"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("APPLY", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainLight, for: .normal)
        button.backgroundColor = UIColor.randevoo.mainColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 15)
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.clear.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        button.addTarget(self, action: #selector(FilterReservationController.applyFilter(_:)), for: .touchUpInside)
        return button
    }()
    
    let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainBlueGrey.withAlphaComponent(0.5)
        view.layer.cornerRadius = 2
        return view
    }()

    
    let bottomView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainLight
        return view
    }()
}
