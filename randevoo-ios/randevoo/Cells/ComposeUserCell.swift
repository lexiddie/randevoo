//
//  ComposeUserCell.swift
//  randevoo
//
//  Created by Xell on 24/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class ComposeUserCell: UITableViewCell {

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
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(userImg)
        userImg.snp.makeConstraints { (make) in
            make.left.lessThanOrEqualTo(self).offset(10)
            make.centerY.equalTo(self)
            make.width.height.equalTo(50)
        }
        addSubview(userName)
        userName.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.lessThanOrEqualTo(userImg.snp.right).offset(10)
        }
    }
    
    let userImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "ProfileIcon")
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let userName:UILabel = {
        let label = UILabel()
        label.text = "N/A"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
}
