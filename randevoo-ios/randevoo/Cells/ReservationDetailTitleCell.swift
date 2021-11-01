//
//  ReservationDetailTitleCell.swift
//  randevoo
//
//  Created by Xell on 3/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

protocol ReservationDetailDelegate {
    func viewStore()
}

class ReservationDetailTitleCell: UICollectionViewCell {
    
    var delegate: ReservationDetailDelegate?
    var isBanned = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.randevoo.mainLight
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        addSubview(background)
        addSubview(shopNameView)
        let height = self.frame.width / 2
        shopNameView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.height.equalTo(height / 4 + 50)
        }
        shopNameView.addSubview(shopName)
        shopName.snp.makeConstraints { (make) in
            make.center.equalTo(shopNameView)
        }
        shopNameView.addSubview(shopImg)
        shopImg.snp.makeConstraints { (make) in
            make.right.equalTo(shopName.snp.left)
            make.centerY.equalTo(shopNameView)
            make.width.height.equalTo(self.frame.width / 12)
        }
        addSubview(statusView)
        statusView.snp.makeConstraints { (make) in
            make.top.equalTo(shopNameView.snp.bottom).offset(5)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.height.equalTo(height / 4)
        }
        statusView.addSubview(reservationStatus)
        reservationStatus.snp.makeConstraints { (make) in
            make.center.equalTo(statusView)
        }
        addSubview(reservationIdView)
        reservationIdView.snp.makeConstraints { (make) in
            make.top.equalTo(statusView.snp.bottom).offset(5)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.height.equalTo(height * 2 / 4)
        }
        reservationIdView.addSubview(idTitle)
        idTitle.snp.makeConstraints { (make) in
            make.top.equalTo(reservationIdView).offset(10)
            make.left.equalTo(reservationIdView).offset(5)
        }
        reservationIdView.addSubview(scheduleTitle)
        scheduleTitle.snp.makeConstraints { (make) in
            make.centerY.equalTo(reservationIdView).offset(10)
            make.left.equalTo(reservationIdView).offset(5)
        }
        reservationIdView.addSubview(id)
        id.snp.makeConstraints { (make) in
            make.top.equalTo(reservationIdView).offset(10)
            make.right.equalTo(reservationIdView).inset(5)
        }
        reservationIdView.addSubview(scheduleDate)
        scheduleDate.snp.makeConstraints { (make) in
            make.centerY.equalTo(reservationIdView).offset(5)
            make.right.equalTo(reservationIdView).inset(5)
        }
        reservationIdView.addSubview(scheduleTime)
        scheduleTime.snp.makeConstraints { (make) in
            make.top.equalTo(scheduleDate.snp.bottom)
            make.right.equalTo(reservationIdView).inset(5)
        }
    }
    
    let background: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.randevoo.mainLight
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.5
        view.layer.masksToBounds = false
        return view
    }()
    
    let shopNameView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let statusView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        return view
    }()
    
    let reservationIdView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let productListView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let shopImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "DefaultPhoto")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = UIScreen.main.bounds.width / 24
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var shopName : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("N/A", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainBlack, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 18)
        button.addTarget(self, action: #selector(viewStore(_:)), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return button
    }()
    
    let reservationStatus : UILabel = {
        let label = UILabel()
        label.text = "Failed"
        label.textColor = UIColor.randevoo.mainRed
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let idTitle : UILabel = {
        let label = UILabel()
        label.text = "ID : "
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let id : UILabel = {
        let label = UILabel()
        label.text = "N0001 "
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .right
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let scheduleTitle : UILabel = {
        let label = UILabel()
        label.text = "Schedule : "
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let scheduleDate : UILabel = {
        let label = UILabel()
        label.text = "31 Dec, 2020"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .right
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let scheduleTime : UILabel = {
        let label = UILabel()
        label.text = "13:30 - 14:00"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .right
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    @IBAction func viewStore(_ sender: Any?) {
        if !isBanned {
            delegate?.viewStore()
        }
    }
    
}
