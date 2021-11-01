//
//  AddToLikeCell.swift
//  randevoo
//
//  Created by Xell on 2/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class AddToLikeCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1, alpha: 0.1)
        addSubview(titleImageView)
        titleImageView.snp.makeConstraints { (make) in
            make.top.bottom.centerX.centerY.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
           
        }
        titleImageView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints{ (make) in
            make.bottom.equalTo(titleImageView).inset(10)
            make.left.right.lessThanOrEqualTo(titleImageView)
            make.height.equalTo(25)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    var titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.randevoo.mainLightGrey.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainLight
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = PaddingLabel()
        label.text = "4,000 Baht"
        label.textColor = UIColor.randevoo.mainBlack
        label.layer.backgroundColor = UIColor.white.withAlphaComponent(0.95).cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 10, 0, 10)
        return label
    }()
    
    
    
}
