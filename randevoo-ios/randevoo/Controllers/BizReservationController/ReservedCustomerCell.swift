//
//  ReservedCustomerCell.swift
//  randevoo
//
//  Created by Lex on 6/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class ReservedCustomerCell: UICollectionViewCell {
    
    private var timestampHelper = TimestampHelper()
    
    private var statuses: [String] = ["Pending", "Approved", "Completed", "Failed", "Canceled", "Declined"]
    
    var reservation: BizReservation? {
        didSet {
            guard let reservation = reservation else { return }
            
            let productString = reservation.products.count > 1 ? "Products: \(String(reservation.products.count))" : "Product: \(String(reservation.products.count))"
            
            statusLabel.text = reservation.status
            if reservation.status == statuses[0] {
                statusLabel.textColor = UIColor.randevoo.mainStatusYellow
                statusBarView.backgroundColor = UIColor.randevoo.mainStatusYellow
            } else if reservation.status == statuses[1] {
                statusLabel.textColor = UIColor.randevoo.mainColor
                statusBarView.backgroundColor = UIColor.randevoo.mainColor
            } else if reservation.status == statuses[2] {
                statusLabel.textColor = UIColor.randevoo.mainStatusGreen
                statusBarView.backgroundColor = UIColor.randevoo.mainStatusGreen
            } else if reservation.status == statuses[3] {
                statusLabel.textColor = UIColor.randevoo.mainStatusRed
                statusBarView.backgroundColor = UIColor.randevoo.mainStatusRed
            } else if reservation.status == statuses[4] {
                statusLabel.textColor = UIColor.randevoo.mainStatusRed
                statusBarView.backgroundColor = UIColor.randevoo.mainStatusRed
            } else if reservation.status == statuses[5] {
                statusLabel.textColor = UIColor.randevoo.mainStatusRed
                statusBarView.backgroundColor = UIColor.randevoo.mainStatusRed
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
//        layer.cornerRadius = 20
//        backgroundColor = UIColor.randevoo.mainLightGray
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(statusBarView)
        statusBarView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(self.frame.height - 20)
            make.width.equalTo(6)
            make.left.equalTo(self).inset(20)
        }
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(reservedStackView)
        contentStackView.addArrangedSubview(customerStackView)
        contentStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(self.frame.height - 20)
            make.width.equalTo(self.frame.width - 51)
            make.right.equalTo(self).inset(20)
        }
        reservedStackView.addArrangedSubview(statusStackView)
        reservedStackView.addArrangedSubview(dateTimeLabel)
        reservedStackView.addArrangedSubview(reservedInfoLabel)
        reservedStackView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentStackView)
            make.height.equalTo(75)
        }
        statusStackView.addArrangedSubview(titleLabel)
        statusStackView.addArrangedSubview(statusLabel)
        statusStackView.snp.makeConstraints { (make) in
            make.centerX.equalTo(reservedStackView)
            make.height.equalTo(25)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(statusStackView)
            make.width.equalTo(70)
            make.height.equalTo(25)
        }
        statusLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(statusStackView)
            make.height.equalTo(25)
            make.width.equalTo(self.frame.width - 121)
            make.right.equalTo(statusStackView)
        }
        customerStackView.addArrangedSubview(customerView)
        customerStackView.addArrangedSubview(infoStackView)
        customerStackView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentStackView)
            make.height.equalTo(80)
        }
        customerView.snp.makeConstraints { (make) in
            make.centerY.equalTo(customerStackView)
            make.height.width.equalTo(80)
        }
        customerView.addSubview(customerImageView)
        customerImageView.snp.makeConstraints { (make) in
            make.center.equalTo(customerView)
            make.height.width.equalTo(60)
        }
        infoStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(customerStackView)
            make.height.equalTo(60)
            make.width.equalTo(self.frame.width - 131)
            make.right.equalTo(customerStackView)
        }
        infoStackView.addArrangedSubview(usernameLabel)
        infoStackView.addArrangedSubview(locationLabel)
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.width.equalTo(self.frame.width - 31)
            make.right.lessThanOrEqualTo(self)
            make.bottom.equalTo(self)
        }
    }
    
    let statusBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.green
        view.layer.cornerRadius = 3
        return view
    }()
    
    let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
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
    
    let statusStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.alignment = .leading
        return stackView
    }()
    
    let titleLabel: UILabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.text = "Status:"
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 0, 0, 0)
        return label
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
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
}
