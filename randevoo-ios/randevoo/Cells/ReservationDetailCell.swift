//
//  ReservationDetailCell.swift
//  randevoo
//
//  Created by Xell on 29/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class ReservationDetailCell: UITableViewCell {

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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        let productWidthHeight = self.frame.width / 2
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
        }
        addSubview(productColor)
        productColor.snp.makeConstraints { (make) in
            make.top.equalTo(productName.snp.bottom).offset(5)
            make.left.equalTo(productImg.snp.right).offset(10)
        }
        addSubview(productSize)
        productSize.snp.makeConstraints { (make) in
            make.centerY.equalTo(productImg)
            make.left.equalTo(productImg.snp.right).offset(10)
        }
        addSubview(productPrice)
        productPrice.snp.makeConstraints { (make) in
            make.top.equalTo(productImg.snp.bottom).inset(30)
            make.left.equalTo(productImg.snp.right).offset(10)
        }
    }
    
    let productImg : UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.randevoo.mainLight
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let productName : UILabel = {
        let label = PaddingLabel()
        label.text = "Air Jordan"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    let productColor : UILabel = {
        let label = PaddingLabel()
        label.text = "Grey"
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    let productSize : UILabel = {
        let label = PaddingLabel()
        label.text = "43"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    let productPrice : UILabel = {
        let label = PaddingLabel()
        label.text = "$1,200"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        return label
    }()

}
