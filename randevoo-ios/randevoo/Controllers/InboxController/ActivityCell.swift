//
//  ActivityCell.swift
//  randevoo
//
//  Created by Lex on 10/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class ActivityCell: UICollectionViewCell {
    
    var activity: Activity? {
        didSet {
            guard let activity = activity else { return }
            
//            let first = [NSAttributedString.Key.font: UIFont(name: "Quicksand-Bold", size: 17), NSAttributedString.Key.foregroundColor : UIColor.black]
//            let second = [NSAttributedString.Key.font: UIFont(name: "Quicksand-Medium", size: 16), NSAttributedString.Key.foregroundColor : UIColor.black]
//
//            let username = NSMutableAttributedString(string: someUsername, attributes: first as [NSAttributedString.Key : Any])
//            let status = NSMutableAttributedString(string: someText, attributes: second as [NSAttributedString.Key : Any])
//            username.append(status)
//            statusLabel.attributedText = username
            
            usernameLabel.text = activity.user.username
            contentLabel.text = activity.content.replaceText(current: "username", update: activity.user.username)
            
            if activity.user.profileUrl != "" {
                userImageView.loadCacheImage(urlString: activity.user.profileUrl)
            } else {
                userImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
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
        addSubview(userStackView)
        userStackView.addArrangedSubview(userView)
        userStackView.addArrangedSubview(infoStackView)
        userStackView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(10)
            make.center.equalTo(self)
            make.height.equalTo(60)
        }
        userView.snp.makeConstraints { (make) in
            make.centerY.equalTo(userStackView)
            make.height.width.equalTo(60)
        }
        userView.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.center.equalTo(userView)
            make.height.width.equalTo(60)
        }
        infoStackView.addArrangedSubview(usernameLabel)
        infoStackView.addArrangedSubview(contentLabel)
        infoStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(userStackView)
            make.height.equalTo(60)
            make.width.equalTo(self.frame.width - 95)
            make.right.equalTo(userStackView)
        }
        usernameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(infoStackView)
            make.height.equalTo(20)
            make.left.right.equalTo(infoStackView)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(infoStackView)
            make.height.equalTo(40)
            make.left.right.equalTo(infoStackView)
        }
    }
    
    let userStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.alignment = .leading
        return stackView
    }()
    
    let userView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let userImageView: UIImageView = {
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
        stackView.distribution = .equalSpacing
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
        label.padding(2, 5, 0, 5)
        return label
    }()
    
    let contentLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Medium", size: 15)
        label.textColor = UIColor.randevoo.mainGray
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.padding(0, 5, 2, 5)
        return label
    }()
}
