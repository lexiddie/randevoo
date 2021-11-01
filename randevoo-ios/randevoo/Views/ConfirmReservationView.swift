//
//  ConfirmReservationView.swift
//  randevoo
//
//  Created by Xell on 19/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class ConfirmReservationView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        let margin = self.frame.width / 4 - 10
        let topHeight = (self.frame.height / 8) + 45
        addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.height.equalTo(topHeight)
        }
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).inset(20)
            make.left.equalTo(self).offset(margin)
        }
        addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).inset(20)
            make.right.equalTo(self).inset(margin)
        }
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(5)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).inset(20)
            make.bottom.equalTo(cancelButton.snp.top)
        }
        topView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topView).offset(10)
            make.centerX.equalTo(self)
        }
        topView.addSubview(shopImg)
        shopImg.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.lessThanOrEqualTo(topView).offset(20)
            make.width.height.equalTo(40)
        }
        topView.addSubview(shopName)
        shopName.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(shopImg.snp.right).offset(20)
            make.right.equalTo(topView).inset(20)
            make.centerY.equalTo(shopImg)
        }
        topView.addSubview(shopLocation)
        shopLocation.snp.makeConstraints { (make) in
            make.top.equalTo(shopImg.snp.bottom).offset(5)
            make.left.lessThanOrEqualTo(topView).offset(20)
            make.right.equalTo(topView).inset(20)
        }
        topView.addSubview(appointmentDate)
        appointmentDate.snp.makeConstraints { (make) in
            make.top.equalTo(shopLocation.snp.bottom).offset(5)
            make.left.equalTo(topView).offset(20)
            make.right.equalTo(topView).inset(20)
        }
        topView.addSubview(totalLabel)
        totalLabel.snp.makeConstraints { (make) in
            make.top.equalTo(appointmentDate.snp.bottom).offset(5)
            make.left.equalTo(topView).offset(20)
            make.right.equalTo(topView).inset(20)
            make.bottom.equalTo(topView)
        }
    }
    
    let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        table.allowsSelection = false
        return table
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirmation"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let shopName: UILabel = {
        let label = UILabel()
        label.text = "Nike"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let shopImg: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let shopLocation: UILabel = {
        let label = UILabel()
        label.text = "Somewhere on Earth"
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let totalLabel: UILabel = {
        let label = UILabel()
        label.text = "Total"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let appointmentDate: UILabel = {
        let label = UILabel()
        label.text = "Mon-30-Feb-20"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gray
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 15
        button.setTitleColor(UIColor.randevoo.mainBlack, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 15)
        button.contentEdgeInsets = UIEdgeInsets(top:15,left: 20,bottom: 15,right: 20)
        button.addTarget(self, action: #selector(ConfirmReservationController.cancel), for: .touchUpInside)
        return button
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.randevoo.mainColor
        button.setTitle("Confirm", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainLight, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 15)
        button.contentEdgeInsets = UIEdgeInsets(top:15,left: 20,bottom: 15,right: 20)
        button.addTarget(self, action: #selector(ConfirmReservationController.confirm), for: .touchUpInside)
        button.layer.cornerRadius = 15
        return button
    }()
    
}


