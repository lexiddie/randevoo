//
//  StoreCell.swift
//  randevoo
//
//  Created by Xell on 31/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class StoreCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(storeImg)
        storeImg.snp.makeConstraints { (make) in
            make.left.lessThanOrEqualTo(self).offset(10)
            make.centerY.equalTo(self)
            make.width.height.equalTo(50)
        }
        addSubview(storeName)
        storeName.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.lessThanOrEqualTo(storeImg.snp.right).offset(10)
        }
        addSubview(removeButton)
        removeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self).inset(10)
            make.width.height.equalTo(15)
        }
    }
    
    let storeImg: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let storeName:UILabel = {
        let label = UILabel()
        label.text = "Bob"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let removeButton : UIButton = {
        let button = UIButton(type: .system)
        let imageView = UIImage.init(named: "DismissIcon")
        button.setImage(imageView, for: .normal)
        button.tintColor = UIColor.randevoo.mainBlack
        return button
    }()
    
}
