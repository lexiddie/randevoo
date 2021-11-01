//
//  PersonalProfileCell.swift
//  randevoo
//
//  Created by Lex on 5/12/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import AlamofireImage

class PersonalProfileCell: UICollectionViewCell {
    
    private let timestampHelper = TimestampHelper()
    
    var personal: PersonalAccount? {
        didSet {
            guard let account = personal else { return }
            
            nameLabel.text = account.name
            joinedDateLabel.text = "Joined in \(String(timestampHelper.toJoinedDate(date: account.createdAt.iso8601withFractionalSeconds!)))"
            
            if account.profileUrl != "" {
                profileImageView.loadCacheProfile(urlString: account.profileUrl)
            } else {
                profileImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
            }
            
            if account.bio != "" {
                bioLabel.text = account.bio
                bioLabel.isHidden = false
            } else {
                bioLabel.isHidden = true
            }
            
            if account.website != "" {
                siteButton.isEnabled = true
                siteButton.isHidden = false
                siteButton.setTitle(account.website, for: .normal)
            } else {
                siteButton.isEnabled = false
                siteButton.isHidden = true
            }
            
            if account.location != "" {
                locationLabel.text = account.location
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
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.left.right.lessThanOrEqualTo(self)
            make.height.equalTo(120)
        }
        profileView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(profileView)
            make.height.width.equalTo(100)
            make.left.lessThanOrEqualTo(profileView).inset(15)
        }
        profileView.addSubview(editProfileButton)
        editProfileButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(profileView)
            make.height.equalTo(40)
            make.width.equalTo(60)
            make.right.lessThanOrEqualTo(profileView).inset(15)
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
    
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("EDIT", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainColor, for: .normal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.titleLabel?.font = UIFont(name: "Quicksand-Medium", size: 17)
        button.backgroundColor = UIColor.clear
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        button.addTarget(self, action: #selector(PersonalController.handleEditProfile(_:)), for: .touchUpInside)
        return button
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
        button.addTarget(self, action: #selector(PersonalController.handleSite(_:)), for: .touchUpInside)
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
