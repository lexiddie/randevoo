//
//  ReservationCell.swift
//  randevoo
//
//  Created by Xell on 27/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class ReservationCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let width = self.frame.width * 2 / 8
        addSubview(background)
        background.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.top.equalTo(self).offset(5)
            make.bottom.equalTo(self).inset(5)
            make.left.right.lessThanOrEqualTo(self).offset(5)
//            make.right.equalTo(self).inset(5)
//            make.bottom.equalTo(self).inset(5)
        }
        background.addSubview(shopImg)
        shopImg.snp.makeConstraints { (make) in
            make.right.equalTo(background).inset(10)
            make.top.equalTo(background).offset(10)
            make.width.height.equalTo(width)
        }
        background.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(background).offset(10)
            make.centerY.equalTo(shopImg)
            make.width.equalTo(self.frame.width * 5 / 8)
            make.height.equalTo(width)
        }
        let height = statusTile.intrinsicContentSize.height + time.intrinsicContentSize.height
        background.addSubview(barView)
        barView.snp.makeConstraints { (make) in
            make.top.equalTo(shopImg.snp.bottom).offset(20)
            make.left.equalTo(background).offset(10)
            make.width.equalTo(6)
            make.height.equalTo(height)
        }
        background.addSubview(statusTile)
        statusTile.snp.makeConstraints { (make) in
            make.top.equalTo(shopImg.snp.bottom).offset(20)
            make.left.equalTo(barView.snp.right).offset(10)
        }
        background.addSubview(status)
        status.snp.makeConstraints { (make) in
            make.top.equalTo(shopImg.snp.bottom).offset(20)
            make.left.equalTo(statusTile.snp.right)
        }
        background.addSubview(time)
        time.snp.makeConstraints { (make) in
            make.top.equalTo(statusTile.snp.bottom)
            make.left.equalTo(barView.snp.right).offset(10)
        }
        background.addSubview(reservationID)
        reservationID.snp.makeConstraints { (make) in
            make.top.equalTo(time.snp.bottom).offset(5)
            make.left.equalTo(background).offset(10)
        }
        background.addSubview(reservationItem)
        reservationItem.snp.makeConstraints { (make) in
            make.top.equalTo(reservationID.snp.bottom).offset(5)
            make.left.equalTo(background).offset(10)
        }
    }
    
    let background : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.1
        view.layer.masksToBounds = false
        return view
    }()
    
    let dateLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.minimumScaleFactor = 18
        label.text = "Dec 31, 2020"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        return label
    }()
    
    let shopImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "DefaultPhoto")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 0
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let barView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.green
        view.layer.cornerRadius = 3
        return view
    }()
    
    let statusTile: UILabel = {
        let label = UILabel()
        label.text = "Status : "
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let status: UILabel = {
        let label = UILabel()
        label.text = "Success"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let time: UILabel = {
        let label = UILabel()
        label.text = "12:00 - 12:30"
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let reservationID: UILabel = {
        let label = UILabel()
        label.text = "ID: N0001"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let reservationItem: UILabel = {
        let label = UILabel()
        label.text = "Total Items: 2"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
}
