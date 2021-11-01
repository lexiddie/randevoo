//
//  SwitchAccountFlexCell.swift
//  randevoo
//
//  Created by Lex on 9/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class SwitchAccountFlexCell: UICollectionViewCell {
    
    var account: Account? {
        didSet {
            usernameLabel.text = account?.username
            
            if account!.isPersonal {
                typeLabel.text = "Personal Account"
            } else {
                typeLabel.text = "Business Account"
            }
            
            if currentAccountId == account!.id {
                checkedImageView.isHidden = false
            } else {
                checkedImageView.isHidden = true
            }
            
            guard let profileImageUrl = account?.profileUrl else { return }
            if profileImageUrl != "" {
                // profileImageView.af.setImage(withURL: URL(string: profileImageUrl)!)
                profileImageView.loadCacheImage(urlString: profileImageUrl)
                
            } else {
                profileImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
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
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.width.equalTo(60)
            make.left.lessThanOrEqualTo(self).inset(15)
        }
        addSubview(containerStackView)
        containerStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(50)
            make.left.equalTo(self).inset(85)
            make.right.equalTo(self).inset(45)
        }
        containerStackView.addArrangedSubview(usernameLabel)
        containerStackView.addArrangedSubview(typeLabel)
        addSubview(checkedImageView)
        checkedImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.width.equalTo(25)
            make.right.lessThanOrEqualTo(self).inset(15)
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 60/2
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
        stackView.spacing = 5
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "alexander"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Personal Account"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let checkedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "CheckedIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 25/2
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()
}
