//
//  AvailabilityView.swift
//  randevoo
//
//  Created by Xell on 16/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit
import HorizonCalendar

class AvailabilityView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        let topViewHeight = self.frame.height / 7
        let bottomViewHeight = self.frame.height / 10
        addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.left.lessThanOrEqualTo(self)
            make.right.equalTo(self)
            make.height.equalTo(topViewHeight)
        }
        addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.height.equalTo(bottomViewHeight)
        }
        topView.addSubview(viewAddressButton)
        viewAddressButton.snp.makeConstraints { (make) in
            make.top.equalTo(topView).offset(10)
            make.right.lessThanOrEqualTo(topView).inset(10)
            make.centerY.equalTo(topView)
        }
        topView.addSubview(reserveBy)
        reserveBy.snp.makeConstraints { (make) in
            make.left.top.lessThanOrEqualTo(topView).offset(10)
        }
        topView.addSubview(shopImg)
        shopImg.snp.makeConstraints { (make) in
            make.top.equalTo(reserveBy.snp.bottom).offset(5)
            make.left.lessThanOrEqualTo(topView).offset(10)
            make.centerY.equalTo(topView)
            make.width.height.equalTo(topViewHeight / 3)
        }
        topView.addSubview(shopName)
        shopName.snp.makeConstraints { (make) in
            make.left.lessThanOrEqualTo(shopImg.snp.right).offset(5)
            make.centerY.equalTo(shopImg)
            make.width.equalTo(self.frame.width / 2)
        }
        topView.addSubview(shopLocation)
        shopLocation.snp.makeConstraints { (make) in
            make.top.equalTo(shopImg.snp.bottom).offset(5)
            make.left.lessThanOrEqualTo(topView).offset(10)
            make.width.equalTo(self.frame.width / 2)
        }
        bottomView.addSubview(selectButton)
        selectButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(bottomView)
            make.centerX.equalTo(self)
        }
    }
    
    
    let topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let middleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainLight
        return view
    }()
    
    let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello"
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    var shopImg: UIImageView = {
        let cornerRadius = (UIScreen.main.bounds.height / 40) - 1
        print("corner \(cornerRadius)")
        let imageView = UIImageView()
        imageView.layer.cornerRadius = cornerRadius
        imageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let reserveBy: UILabel = {
        let label = UILabel()
        label.text = "Reserved By"
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.font = UIFont(name: "Quicksand-Regular", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let shopName: UILabel = {
        let label = UILabel()
        label.text = "Nike"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let shopLocation: UILabel = {
        let label = UILabel()
        label.text = "SomeWhere on Earth"
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.font = UIFont(name: "Quicksand-Regular", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let viewAddressButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View address", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainColor, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 20)
        button.addTarget(self, action:#selector(AvailabilityController.showMap), for: .touchUpInside)
        return button
    }()
    
    let selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.randevoo.mainLight, for: .normal)
        button.backgroundColor = UIColor.randevoo.mainColor
        button.layer.cornerRadius = 15
        button.setTitle("Select", for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 15)
        button.addTarget(self, action: #selector(AvailabilityController().showAvailableHour), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top:15,left: 20,bottom: 15,right: 20)
        return button
    }()
    
}
