//
//  ReservationDetailProductCell.swift
//  randevoo
//
//  Created by Xell on 3/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class ReservationDetailProductCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.randevoo.mainLight
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        let productWidthHeight = self.frame.width / 3
        let textWidth = self.frame.width - (productWidthHeight + 30)
        addSubview(productImg)
        productImg.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.width.height.equalTo(productWidthHeight)
        }
        addSubview(productName)
        productName.snp.makeConstraints { (make) in
            make.top.equalTo(productImg).offset(5)
            make.left.equalTo(productImg.snp.right).offset(10)
            make.right.equalTo(self).inset(10)
            make.width.equalTo(textWidth)
        }
        addSubview(productColor)
        productColor.snp.makeConstraints { (make) in
            make.top.equalTo(productName.snp.bottom).offset(5)
            make.left.equalTo(productImg.snp.right).offset(10)
            make.right.equalTo(self).inset(10)
            make.width.equalTo(textWidth)
        }
        addSubview(productSize)
        productSize.snp.makeConstraints { (make) in
            make.centerY.equalTo(productImg)
            make.left.equalTo(productImg.snp.right).offset(10)
            make.right.equalTo(self).inset(10)
            make.width.equalTo(textWidth)
        }
        addSubview(productQuantity)
        productQuantity.snp.makeConstraints { (make) in
            make.top.equalTo(productSize.snp.bottom)
            make.left.equalTo(productImg.snp.right).offset(10)
        }
        addSubview(productPrice)
        productPrice.snp.makeConstraints { (make) in
            make.top.equalTo(productImg.snp.bottom).inset(20)
            make.left.equalTo(productImg.snp.right).offset(10)
            make.right.equalTo(self).inset(10)
            make.width.equalTo(textWidth)
        }
        addSubview(background)
        background.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        background.addSubview(isBannedLabel)
        isBannedLabel.snp.makeConstraints { (make) in
            make.center.equalTo(background)
        }
    }
    
    let background: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let isBannedLabel: UILabel = {
        let label = PaddingLabel()
        label.text = ""
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.padding(7, 7, 7, 7)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    
    let productImg: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.randevoo.mainLight
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    let productName: UILabel = {
        let label = PaddingLabel()
        label.text = "N/A"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    let productColor: UILabel = {
        let label = PaddingLabel()
        label.text = "N/A"
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    let productSize: UILabel = {
        let label = PaddingLabel()
        label.text = "N/A"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    let productQuantity: UILabel = {
        let label = PaddingLabel()
        label.text = "N/A"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    let productPrice: UILabel = {
        let label = PaddingLabel()
        label.text = "$N/A"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
}
