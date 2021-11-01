//
//  AddToListCollectionHeader.swift
//  randevoo
//
//  Created by Xell on 7/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class AddToListCollectionHeader: UICollectionViewCell {
    
    var imgUrl = ""
    var productName = ""
    var productPrice = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.randevoo.mainLight
        setupUI()
        setupInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(ProductImg)
        ProductImg.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(20)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.width.height.equalTo(150)
        }
        addSubview(productNameLabel)
        productNameLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(ProductImg.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
        }
        addSubview(productPriceLabel)
        productPriceLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(productNameLabel.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
        }
    }
    
    private func setupInfo() {
        print("run this func")
        print(imgUrl)
        ProductImg.loadCacheImage(urlString: imgUrl)
        productNameLabel.text = productName
    }
    
    let ProductImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "DefaultPhoto")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 10
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.backgroundColor = UIColor.white
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let productNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Shoe"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let productPriceLabel: UILabel = {
        let label = UILabel()
        label.text = "1,000 Baht"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    
}
