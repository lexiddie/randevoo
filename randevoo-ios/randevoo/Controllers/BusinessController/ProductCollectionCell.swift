//
//  ProductCollectionCell.swift
//  randevoo
//
//  Created by Lex on 21/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class ProductCollectionCell: UICollectionViewCell {
    
    var collection: Collection? {
        didSet {
            guard let collection = collection else { return }

            if collection.bizProfileUrl != "" {
                storeImageView.loadCacheImage(urlString: collection.bizProfileUrl)
            } else {
                storeImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
            }
            storeName.text = collection.bizName
            productImageView.loadCacheImage(urlString: collection.photoUrl)
            nameLabel.text = collection.name
            quantityLabel.text = "\(collection.products.count) PRODUCTS"
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
        addSubview(productImageView)
        productImageView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(10)
            make.center.equalTo(self)
        }
        productImageView.addSubview(storeStackView)
        storeStackView.addArrangedSubview(storeImageView)
        storeStackView.addArrangedSubview(storeName)
        storeStackView.snp.makeConstraints { (make) in
            make.top.equalTo(productImageView).inset(20)
            make.left.right.equalTo(productImageView).inset(10)
            make.centerX.equalTo(productImageView)
            make.height.equalTo(40)
        }
        storeImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(storeStackView)
            make.height.width.equalTo(40)
        }
        storeName.snp.makeConstraints { (make) in
            make.centerY.equalTo(storeStackView)
            make.height.equalTo(25)
            make.width.equalTo(self.frame.width - 90)
            make.right.equalTo(storeStackView)
        }
        productImageView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints{ (make) in
            make.bottom.equalTo(productImageView).inset(10)
            make.left.equalTo(productImageView).inset(10)
            make.right.lessThanOrEqualTo(productImageView).inset(10)
            make.height.equalTo(30)
        }
        productImageView.addSubview(quantityLabel)
        quantityLabel.snp.makeConstraints{ (make) in
            make.bottom.equalTo(nameLabel.snp.top).offset(-5)
            make.left.equalTo(productImageView).inset(10)
            make.right.lessThanOrEqualTo(productImageView).inset(10)
            make.height.equalTo(25)
        }
    }
    
    var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.randevoo.mainLight.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainLight
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let storeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.alignment = .leading
        return stackView
    }()
    
    let storeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 40/2
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.randevoo.mainWhiteGray.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainWhiteGray
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let storeName: UILabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = PaddingLabel()
        label.textColor = UIColor.white
        label.layer.backgroundColor = UIColor.black.withAlphaComponent(0.2).cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 23)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let quantityLabel: UILabel = {
        let label = PaddingLabel()
        label.textColor = UIColor.white
        label.layer.backgroundColor = UIColor.black.withAlphaComponent(0.2).cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
}
