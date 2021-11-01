//
//  StoreProfileCell.swift
//  randevoo
//
//  Created by Lex on 28/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

protocol StoreProfileCellDelegate {
    func didChangeToListingView()
    func didChangeToCollectionView()
    func didChangeToAboutView()
}

class StoreProfileCell: UICollectionViewCell {
    
    var store: StoreAccount? {
        didSet {
            guard let store = store else { return }
            
            nameLabel.text = store.name
            storeTypeLabel.text = store.type
            
//            if businessAccount?.id == store.id && !isPersonalAccount {
//                editProfileButton.isHidden = false
//            } else {
//                editProfileButton.isHidden = true
//            }
            
            if store.profileUrl != "" {
                profileImageView.loadCacheProfile(urlString: store.profileUrl)
            } else {
                profileImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
            }
            
            if store.bio != "" {
                bioLabel.text = store.bio
                bioLabel.isHidden = false
            } else {
                bioLabel.isHidden = true
            }
            
            if store.website != "" {
                siteButton.isEnabled = true
                siteButton.isHidden = false
                siteButton.setTitle(store.website, for: .normal)
            } else {
                siteButton.isEnabled = false
                siteButton.isHidden = true
            }
            
            if store.location != "" {
                locationLabel.text = store.location
                locationLabel.isHidden = false
            } else {
                locationLabel.isHidden = true
            }
            if store.isBanned {
                isBanned.isHidden = false
            } else {
                isBanned.isHidden = true
            }
        
        }
    }
    
    var delegate: StoreProfileCellDelegate?
    
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
        profileView.addSubview(editProfileButton)
        editProfileButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(profileView)
            make.height.equalTo(40)
            make.width.equalTo(60)
            make.right.lessThanOrEqualTo(profileView).inset(15)
        }
        profileView.addSubview(isBanned)
        isBanned.snp.makeConstraints { (make) in
            make.centerY.equalTo(profileImageView)
            make.right.equalTo(profileView).inset(10)
        }
        addSubview(containerStackView)
        containerStackView.snp.makeConstraints { (make) in
            make.top.equalTo(profileView.snp.bottom)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        containerStackView.addArrangedSubview(nameLabel)
        containerStackView.addArrangedSubview(storeTypeLabel)
        containerStackView.addArrangedSubview(bioLabel)
        containerStackView.addArrangedSubview(siteButton)
        containerStackView.addArrangedSubview(locationLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.width.equalTo(self.frame.width - 40)
        }
        storeTypeLabel.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.width.equalTo(self.frame.width - 40)
        }
        bioLabel.snp.makeConstraints { (make) in
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
        addSubview(actionStackView)
        actionStackView.snp.makeConstraints { (make) in
            make.top.equalTo(containerStackView.snp.bottom).offset(20)
            make.bottom.equalTo(self)
            make.centerX.equalTo(self)
            make.height.equalTo(50)
            make.left.right.lessThanOrEqualTo(self)
        }
        actionStackView.addArrangedSubview(listingButton)
        listingButton.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width / 2)
//            make.width.equalTo(self.frame.width / 3)
            make.height.equalTo(50)
        }
//        actionStackView.addArrangedSubview(collectionButton)
//        collectionButton.snp.makeConstraints { (make) in
//            make.width.equalTo(self.frame.width / 3)
//            make.height.equalTo(50)
//        }
        actionStackView.addArrangedSubview(aboutButton)
        aboutButton.snp.makeConstraints { (make) in
            make.width.equalTo(self.frame.width / 2)
//            make.width.equalTo(self.frame.width / 3)
            make.height.equalTo(50)
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
    
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("EDIT", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainColor, for: .normal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.titleLabel?.font = UIFont(name: "Quicksand-Medium", size: 17)
        button.backgroundColor = UIColor.clear
        button.isHidden = true
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        button.addTarget(self, action: #selector(StoreController.handleEditProfile(_:)), for: .touchUpInside)
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
    
    let isBanned: UILabel = {
        let label = PaddingLabel()
        label.textColor = UIColor.randevoo.mainLight
        label.layer.backgroundColor = UIColor.randevoo.mainRed.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.text = "Banned"
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let storeTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
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
    
    let siteButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "Quicksand-Medium", size: 17)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.randevoo.mainDarkBlue, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentVerticalAlignment = .center
        button.titleLabel?.textAlignment = .left
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.addTarget(self, action: #selector(BusinessController.handleSite(_:)), for: .touchUpInside)
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
    
    let actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var listingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Listings", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainColor, for: .normal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 17)
        button.backgroundColor = UIColor.clear
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        button.addTarget(self, action: #selector(handleListing(_:)), for: .touchDown)
        return button
    }()
    
    @IBAction func handleListing(_ sender: Any?) {
        delegate?.didChangeToListingView()
        listingButton.setTitleColor(UIColor.randevoo.mainColor, for: .normal)
//        collectionButton.setTitleColor(UIColor.randevoo.mainBlueGrey, for: .normal)
        aboutButton.setTitleColor(UIColor.randevoo.mainBlueGrey, for: .normal)
    }
    
//    lazy var collectionButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Collections", for: .normal)
//        button.setTitleColor(UIColor.randevoo.mainBlueGrey, for: .normal)
//        button.contentHorizontalAlignment = .center
//        button.contentVerticalAlignment = .center
//        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 17)
//        button.backgroundColor = UIColor.clear
//        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
//        button.addTarget(self, action: #selector(handleCollection(_:)), for: .touchDown)
//        return button
//    }()
//
//    @IBAction func handleCollection(_ sender: Any?) {
//        delegate?.didChangeToCollectionView()
//        listingButton.setTitleColor(UIColor.randevoo.mainBlueGrey, for: .normal)
//        collectionButton.setTitleColor(UIColor.randevoo.mainColor, for: .normal)
//        aboutButton.setTitleColor(UIColor.randevoo.mainBlueGrey, for: .normal)
//    }
    
    lazy var aboutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("About", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainBlueGrey, for: .normal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 17)
        button.backgroundColor = UIColor.clear
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        button.addTarget(self, action: #selector(handleAbout(_:)), for: .touchDown)
        return button
    }()
    
    @IBAction func handleAbout(_ sender: Any?) {
        delegate?.didChangeToAboutView()
        listingButton.setTitleColor(UIColor.randevoo.mainBlueGrey, for: .normal)
//        collectionButton.setTitleColor(UIColor.randevoo.mainBlueGrey, for: .normal)
        aboutButton.setTitleColor(UIColor.randevoo.mainColor, for: .normal)
    }
}
