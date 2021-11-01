    //
//  ProductCollectionCell.swift
//  randevoo
//
//  Created by Lex on 15/8/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class ProductGridCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1, alpha: 0.1)
        let width = self.frame.width - 20
        addSubview(productImageView)
        productImageView.snp.makeConstraints { (make) in
            make.top.bottom.centerX.centerY.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
           
        }
        productImageView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints{ (make) in
            make.bottom.equalTo(productImageView).inset(10)
            make.left.right.lessThanOrEqualTo(productImageView)
            make.height.equalTo(25)
            make.width.equalTo(width)
        }
        addSubview(background)
        background.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        background.addSubview(isBannedLabel)
        isBannedLabel.snp.makeConstraints { (make) in
            make.center.equalTo(background)
            make.left.right.equalTo(self).offset(10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.randevoo.mainLightGrey.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainLight
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let priceLabel: UILabel = {
        let label = PaddingLabel()
        label.text = "N/A"
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
    
    let background: UIView = {
        let view = UIView()
        return view
    }()
    
    let isBannedLabel: UILabel = {
        let label = PaddingLabel()
        label.text = ""
        label.textColor = UIColor.randevoo.mainRed.withAlphaComponent(0.8)
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.backgroundColor = UIColor.white
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.minimumScaleFactor = 0.5
        label.padding(7, 7, 7, 7)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
}
