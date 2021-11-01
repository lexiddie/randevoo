//
//  BizListingCell.swift
//  randevoo
//
//  Created by Lex on 1/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class BizListingCell: UICollectionViewCell {
    
    var product: Product? {
        didSet {
            guard let product = product else { return }
            productImageView.loadCacheImage(urlString: product.photoUrls[0])
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
        addSubview(productImageView)
        productImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self)
        }
        productImageView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.height.equalTo(62)
            make.left.right.lessThanOrEqualTo(self)
            make.bottom.equalTo(self)
        }
        infoStackView.addArrangedSubview(nameLabel)
        infoStackView.addArrangedSubview(priceLabel)
        nameLabel.snp.makeConstraints{ (make) in
            make.height.equalTo(30)
        }
        priceLabel.snp.makeConstraints{ (make) in
            make.height.equalTo(30)
        }
    }

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

    let infoStackView: UIStackView = {
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
