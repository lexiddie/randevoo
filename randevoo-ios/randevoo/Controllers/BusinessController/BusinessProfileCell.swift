//
//  BusinessProfileCell.swift
//  randevoo
//
//  Created by Lex on 5/12/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

protocol BusinessProfileCellDelegate {
    func didChangeToListingView()
    func didChangeToCollectionView()
    func didChangeToAboutView()
}

class BusinessProfileCell: UICollectionViewCell {
    
    var business: BusinessAccount? {
        didSet {
            guard let business = business else { return }
            
            nameLabel.text = business.name
            storeTypeLabel.text = business.type
            
            if business.profileUrl != "" {
                profileImageView.loadCacheProfile(urlString: business.profileUrl)
            } else {
                profileImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
            }
            
            if business.bio != "" {
                bioLabel.text = business.bio
                bioLabel.isHidden = false
            } else {
                bioLabel.isHidden = true
            }
            
            if business.website != "" {
                siteButton.isEnabled = true
                siteButton.isHidden = false
                siteButton.setTitle(business.website, for: .normal)
            } else {
                siteButton.isEnabled = false
                siteButton.isHidden = true
            }
            
            if business.location != "" {
                locationLabel.text = business.location
                locationLabel.isHidden = false
            } else {
                locationLabel.isHidden = true
            }
        }
    }
    
    var delegate: BusinessProfileCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
//        initiateFocusBarView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func initiateFocusBarView() {
//        actionStackView.addSubview(focusBarView)
//        let x = actionStackView.frame.origin.x
//        let y = CGFloat(40)
//        let width = (frame.width) / 3
//        self.focusBarView.frame = CGRect(x: x, y: y, width: width, height: 2)
//    }
    
//    let focusBarView: UIView = {
//        let view = UIView()
//        view.layer.cornerRadius = 1
//        view.backgroundColor = UIColor.randevoo.mainColor
//        return view
//    }()
    
//    func animateBar(indexPath: Int, duration: Double = 0.3) {
//        let x = actionStackView.frame.origin.x
//        let y = CGFloat(40)
//        let width = (frame.width) / 3
//        UIView.animate(withDuration: duration, animations: {
//            self.focusBarView.frame = CGRect(x: x + (width * CGFloat(indexPath)), y: y, width: width, height: 2)
//        }, completion: nil)
//    }
    
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
        button.isHidden = false
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 8)
        button.addTarget(self, action: #selector(BusinessController.handleEditProfile(_:)), for: .touchUpInside)
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
