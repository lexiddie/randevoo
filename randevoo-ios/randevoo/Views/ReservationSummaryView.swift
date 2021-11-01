//
//  AppointmentSummaryView.swift
//  randevoo
//
//  Created by Xell on 22/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class ReservationSummaryView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(bottomView)
        bottomView.snp.makeConstraints{(make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.left.lessThanOrEqualTo(self)
            make.right.equalTo(self)
            make.height.equalTo(70)
        }
        addSubview(mainCollectionView)
        mainCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.equalTo(self)
            make.bottom.equalTo(bottomView.snp.top).inset(10)
        }
        bottomView.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.top.equalTo(mainCollectionView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(bottomView).offset(10)
            make.bottom.equalTo(bottomView)
            make.center.equalTo(bottomView)
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
    
    let bottomView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainLight
        return view
    }()
    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.randevoo.mainColor
        button.setTitle("DONE", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainLight, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 18)
        button.contentEdgeInsets = UIEdgeInsets(top:15,left: 20,bottom: 15,right: 20)
        button.addTarget(self, action: #selector(ReservationSummaryController().done), for: .touchUpInside)
        button.layer.cornerRadius = 15
        return button
    }()

}
