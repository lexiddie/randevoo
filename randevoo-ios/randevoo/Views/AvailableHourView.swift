//
//  AvailableHourView.swift
//  randevoo
//
//  Created by Xell on 19/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class AvailableHourView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        let topWidth = self.frame.width/5 + 20
        let bottomWidth = self.frame.width/6
        addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.left.right.lessThanOrEqualTo(self)
            make.height.equalTo(topWidth)
        }
        addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.height.equalTo(bottomWidth)
        }
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.bottom.equalTo(bottomView.snp.top)
            make.left.right.lessThanOrEqualTo(self)
        }
        topView.addSubview(selectionLabel)
        selectionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topView).offset(10)
            make.centerX.equalTo(self)
        }
        topView.addSubview(shopImg)
        shopImg.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.top.equalTo(selectionLabel.snp.bottom).offset(5)
            make.width.height.equalTo(40)
        }
        topView.addSubview(shopName)
        shopName.snp.makeConstraints { (make) in
            make.left.equalTo(shopImg.snp.right).offset(10)
            make.centerY.equalTo(shopImg)
        }
        topView.addSubview(date)
        date.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.top.equalTo(shopImg.snp.bottom).offset(5)
        }
        bottomView.addSubview(dateWithTime)
        dateWithTime.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(bottomView)
        }
        bottomView.addSubview(confirm)
        confirm.snp.makeConstraints { (make) in
            make.right.equalTo(self).inset(10)
            make.centerY.equalTo(bottomView)
        }
        
    }
    
    let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        table.allowsSelection = true
        return table
    }()

    let topView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainLight
        return view
    }()
    
    let bottomView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainLight
        return view
    }()
    
    let selectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Selection"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let shopImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.randevoo.mainWhiteGray.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainWhiteGray
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let shopName: UILabel = {
        let label = UILabel()
        label.text = "Nike"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let date: UILabel = {
        let label = UILabel()
        label.text = "Mon-10-2020"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let dateWithTime: UILabel = {
        let label = UILabel()
        label.text = "Mon-10-2020"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let confirm: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainLight, for: .normal)
        button.backgroundColor = UIColor.randevoo.mainLight
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 15)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top:10,left: 15,bottom: 10,right: 15)
        button.addTarget(self, action: #selector(AvailableHourController.pushToConfirm), for: .touchUpInside)
        return button
    }()
}
