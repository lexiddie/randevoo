//
//  MessengerCell.swift
//  randevoo
//
//  Created by Lex on 10/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class MessengerCell: UICollectionViewCell {
    
    var messenger: Messenger? {
        didSet {
            guard let messenger = messenger else { return }
            guard let user = messenger.user else { return }
     
            usernameLabel.text = user.username
  
            if user.profileUrl != "" {
                userImageView.loadCacheImage(urlString: user.profileUrl)
            } else {
                userImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
            }
            
            guard let chat = messenger.recent else { return }
            
            chatLabel.text = chat.getText(accountId: user.id)
            
            if !chat.isRead {
                chatLabel.font = UIFont(name: "Quicksand-Bold", size: 18)
                if chat.senderId != user.id {
                    chatLabel.textColor = UIColor.randevoo.mainGray
                } else {
                    chatLabel.textColor = UIColor.randevoo.mainBlack
                }
            } else {
                chatLabel.font = UIFont(name: "Quicksand-Medium", size: 18)
                chatLabel.textColor = UIColor.randevoo.mainGray
            }
            
            if chat.content == "" || chat.type == "" {
                usernameLabel.padding(0, 5, 0, 5)
                chatLabel.isHidden = true
            } else {
                usernameLabel.padding(5, 5, 0, 5)
                chatLabel.isHidden = false
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
        addSubview(messageStackView)
        messageStackView.addArrangedSubview(userImageView)
        messageStackView.addArrangedSubview(infoStackView)
        messageStackView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(60)
        }
        userImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(messageStackView)
            make.height.width.equalTo(60)
        }
        infoStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(messageStackView)
            make.height.equalTo(60)
            make.width.equalTo(self.frame.width - 90)
            make.right.equalTo(messageStackView)
        }
        infoStackView.addArrangedSubview(usernameLabel)
        infoStackView.addArrangedSubview(chatLabel)
    }
    
    let messageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.alignment = .leading
        return stackView
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
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(5, 5, 0, 5)
        return label
    }()
    
    let chatLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textColor = UIColor.randevoo.mainGray
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 5, 5)
        return label
    }()
}
