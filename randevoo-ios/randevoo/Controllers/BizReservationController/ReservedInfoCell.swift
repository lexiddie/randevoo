//
//  ReservedInfoCell.swift
//  randevoo
//
//  Created by Lex on 6/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class ReservedInfoCell: UICollectionViewCell {
    
    private var timestampHelper = TimestampHelper()
    
    private var statuses: [String] = ["Pending", "Approved", "Completed", "Failed", "Canceled", "Declined"]
    
    var reservation: BizReservation? {
        didSet {
            guard let reservation = reservation else { return }
            
            let productString = reservation.products.count > 1 ? "Products: \(String(reservation.products.count))" : "Product: \(String(reservation.products.count))"
            
            statusLabel.text = reservation.status
            if reservation.status == statuses[0] {
                statusLabel.textColor = UIColor.randevoo.mainStatusYellow
                statusLabel.layer.backgroundColor = UIColor.randevoo.mainStatusYellow.withAlphaComponent(0.3).cgColor
            } else if reservation.status == statuses[1] {
                statusLabel.textColor = UIColor.randevoo.mainColor
                statusLabel.layer.backgroundColor = UIColor.randevoo.mainColor.withAlphaComponent(0.3).cgColor
            } else if reservation.status == statuses[2] {
                statusLabel.textColor = UIColor.randevoo.mainStatusGreen
                statusLabel.layer.backgroundColor = UIColor.randevoo.mainStatusGreen.withAlphaComponent(0.3).cgColor
            } else if reservation.status == statuses[3] {
                statusLabel.textColor = UIColor.randevoo.mainStatusRed
                statusLabel.layer.backgroundColor = UIColor.randevoo.mainStatusRed.withAlphaComponent(0.3).cgColor
            } else if reservation.status == statuses[4] {
                statusLabel.textColor = UIColor.randevoo.mainStatusRed
                statusLabel.layer.backgroundColor = UIColor.randevoo.mainStatusRed.withAlphaComponent(0.3).cgColor
            } else if reservation.status == statuses[5] {
                statusLabel.textColor = UIColor.randevoo.mainStatusRed
                statusLabel.layer.backgroundColor = UIColor.randevoo.mainStatusRed.withAlphaComponent(0.3).cgColor
            }
            
            let date = reservation.timeslot.date.fetchDateISO
            
            dateTimeLabel.text = "\(String(timestampHelper.toDateStandard(date: date!))), \(String(reservation.timeslot.time.removeWhitespace()))"
            reservedInfoLabel.text = "ID: \(String(reservation.qrCode)) | \(String(productString))"
            usernameLabel.text = reservation.user.username
            locationLabel.text = reservation.user.location
            
            if reservation.user.location == "" {
                usernameLabel.padding(0, 5, 0, 5)
                locationLabel.isHidden = true
            } else {
                usernameLabel.padding(20, 5, 0, 5)
                locationLabel.isHidden = false
            }
            
            if reservation.user.profileUrl != "" {
                customerImageView.loadCacheImage(urlString: (reservation.user.profileUrl)!)
            } else {
                customerImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
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
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(customerLabel)
        customerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.height.equalTo(35)
            make.centerX.equalTo(self)
        }
        addSubview(customerStackView)
        customerStackView.addArrangedSubview(customerView)
        customerStackView.addArrangedSubview(infoStackView)
        customerStackView.snp.makeConstraints { (make) in
            make.top.equalTo(customerLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(80)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        customerView.snp.makeConstraints { (make) in
            make.centerY.equalTo(customerStackView)
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
        customerView.addSubview(customerImageView)
        customerImageView.snp.makeConstraints { (make) in
            make.center.equalTo(customerView)
            make.height.width.equalTo(60)
        }
        infoStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(customerStackView)
            make.height.equalTo(60)
            make.width.equalTo(self.frame.width - 120)
            make.right.equalTo(customerStackView)
        }
        infoStackView.addArrangedSubview(usernameLabel)
        infoStackView.addArrangedSubview(locationLabel)
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(customerStackView.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(50)
            make.left.right.lessThanOrEqualTo(20)
        }
        addSubview(reservedStackView)
        reservedStackView.addArrangedSubview(dateTimeLabel)
        reservedStackView.addArrangedSubview(reservedInfoLabel)
        reservedStackView.snp.makeConstraints { (make) in
            make.top.equalTo(statusLabel.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(50)
            make.left.right.lessThanOrEqualTo(20)
            make.bottom.equalTo(self).inset(10)
        }
    }
    
    let customerLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "Reserved By"
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 10
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let customerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.alignment = .leading
        return stackView
    }()
    
    let customerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let customerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 60/2
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.randevoo.mainWhiteGray.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainWhiteGray
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let usernameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(20, 5, 0, 5)
        return label
    }()
    
    let locationLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 16)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 20, 5)
        return label
    }()
    
    let statusLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 10
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let reservedStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let dateTimeLabel: UILabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainPink
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let reservedInfoLabel: UILabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
}
