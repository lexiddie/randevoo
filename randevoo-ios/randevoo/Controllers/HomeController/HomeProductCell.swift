//
//  HomeProductCell.swift
//  randevoo
//
//  Created by Xell on 15/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit
import SnapKit

class HomeProductCell: UICollectionViewCell {
    
    var product: ListProduct? {
        didSet {
            guard let product = product else { return }
            if product.bizProfileUrl != "" {
                storeImageView.loadCacheImage(urlString: product.bizProfileUrl)
            } else {
                storeImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
            }
            storeUsernameLabel.text = product.bizUsername
            storeLocationLabel.text = product.bizLocation
            productImageView.loadCacheImage(urlString: product.photoUrl)
            nameLabel.text = product.name
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let priceFormat = numberFormatter.string(from: NSNumber(value: product.price))
            priceLabel.text = "฿\(String(priceFormat!))"
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
        addSubview(storeStackView)
        storeStackView.addArrangedSubview(storeImageView)
        storeStackView.addArrangedSubview(infoStackView)
        storeStackView.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.left.right.lessThanOrEqualTo(self).inset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        storeImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(storeStackView)
            make.height.width.equalTo(40)
        }
        infoStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(storeStackView)
            make.height.equalTo(40)
            make.width.equalTo(self.frame.width - 70)
            make.right.equalTo(storeStackView)
        }
        infoStackView.addArrangedSubview(storeUsernameLabel)
        infoStackView.addArrangedSubview(storeLocationLabel)
        addSubview(productImageView)
        productImageView.snp.makeConstraints { (make) in
            make.top.equalTo(storeStackView.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self)
        }
//        productImageView.addSubview(priceLabel)
//        priceLabel.snp.makeConstraints{ (make) in
//            make.bottom.equalTo(productImageView).inset(10)
//            make.left.right.lessThanOrEqualTo(productImageView)
//            make.height.equalTo(25)
//        }
        productImageView.addSubview(productStackView)
        productStackView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.height.equalTo(62)
            make.left.right.lessThanOrEqualTo(self)
            make.bottom.equalTo(self)
        }
        productStackView.addArrangedSubview(nameLabel)
        productStackView.addArrangedSubview(priceLabel)
        nameLabel.snp.makeConstraints{ (make) in
            make.height.equalTo(30)
        }
        priceLabel.snp.makeConstraints{ (make) in
            make.height.equalTo(30)
        }
    }
    
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
        imageView.layer.borderWidth = 2
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
    
    let storeUsernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Fetching name..."
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    let storeLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "Fetching location.."
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 16)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()

    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 0
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.randevoo.mainLight.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainLight
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let productStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.spacing = 2
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let nameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.layer.backgroundColor = UIColor.white.withAlphaComponent(0.95).cgColor
        label.layer.cornerRadius = 5
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 10, 0, 10)
        return label
    }()
    
    let priceLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.layer.backgroundColor = UIColor.white.withAlphaComponent(0.95).cgColor
        label.layer.cornerRadius = 5
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 10, 0, 10)
        return label
    }()
    
}
