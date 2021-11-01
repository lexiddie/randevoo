//
//  CustomerProfileCell.swift
//  randevoo
//
//  Created by Lex on 31/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class CustomerProfileCell: UICollectionViewCell {
    
    private let timestampHelper = TimestampHelper()
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            
            nameLabel.text = user.name
            joinedDateLabel.text = "Joined in \(String(timestampHelper.toJoinedDate(date: user.createdAt.iso8601withFractionalSeconds!)))"
            
            if user.profileUrl != "" {
                profileImageView.loadCacheProfile(urlString: user.profileUrl)
            } else {
                profileImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
            }
            
            if user.bio != "" {
                bioLabel.text = user.bio
                bioLabel.isHidden = false
            } else {
                bioLabel.isHidden = true
            }
            
            if user.website != "" {
                siteButton.isEnabled = true
                siteButton.isHidden = false
                siteButton.setTitle(user.website, for: .normal)
            } else {
                siteButton.isEnabled = false
                siteButton.isHidden = true
            }
            
            if user.location != "" {
                locationLabel.text = user.location
                locationLabel.isHidden = false
            } else {
                locationLabel.isHidden = true
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
        addSubview(profileView)
        profileView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.centerX.equalTo(self)
            make.height.equalTo(120)
        }
        profileView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(profileView)
            make.height.width.equalTo(100)
            make.left.lessThanOrEqualTo(profileView).inset(15)
        }
        addSubview(containerStackView)
        containerStackView.snp.makeConstraints { (make) in
            make.top.equalTo(profileView.snp.bottom)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        containerStackView.addArrangedSubview(nameLabel)
        containerStackView.addArrangedSubview(bioLabel)
        containerStackView.addArrangedSubview(joinedDateLabel)
        containerStackView.addArrangedSubview(siteButton)
        containerStackView.addArrangedSubview(locationLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.width.equalTo(self.frame.width - 40)
        }
        bioLabel.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width - 40)
        }
        joinedDateLabel.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width - 40)
        }
        siteButton.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.width.equalTo(self.frame.width - 40)
        }
        locationLabel.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.width.equalTo(self.frame.width - 40)
        }
    }
    
    let profileView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 100/2
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.randevoo.mainWhiteGray.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainWhiteGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 0
        return label
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 0
        return label
    }()
    
    let joinedDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let siteButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "Quicksand-Medium", size: 17)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.randevoo.mainDarkBlue, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentVerticalAlignment = .center
        button.titleLabel?.textAlignment = .left
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.addTarget(self, action: #selector(CustomerController.handleSite(_:)), for: .touchUpInside)
        return button
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.randevoo.mainDarkBlue
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 0
        return label
    }()
}
