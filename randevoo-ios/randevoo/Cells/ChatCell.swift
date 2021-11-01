//
//  ChatCell.swift
//  randevoo
//
//  Created by Xell on 5/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(userImg)
        userImg.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.width.height.equalTo(60)
        }
        addSubview(userName)
        userName.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.left.equalTo(userImg.snp.right).offset(10)
        }
        addSubview(lastChat)
        let imgWidth  = userImg.intrinsicContentSize.width - 40
        lastChat.snp.makeConstraints { (make) in
            make.top.equalTo(userName.snp.bottom).offset(10)
            make.left.equalTo(userImg.snp.right).offset(10)
            make.right.equalTo(self).inset(10)
            make.width.equalTo(imgWidth)
        }
    }
    
    let userImg: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = 30
        imageView.image = UIImage.init(named: "ProfileSelected")
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let userName: UILabel = {
        let label = UILabel()
        label.text = "N/A"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let lastChat: UILabel = {
        let label = UILabel()
        label.text = "N/A"
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.font = UIFont(name: "Quicksand-Regular", size: 18)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
}
