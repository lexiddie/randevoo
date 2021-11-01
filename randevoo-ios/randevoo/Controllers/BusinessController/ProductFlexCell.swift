//
//  ProductFlexCell.swift
//  randevoo
//
//  Created by Lex on 20/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class ProductFlexCell: UICollectionViewCell {
    
    var product: ListProduct? {
        didSet {
            guard let product = product else { return }
            productImageView.loadCacheImage(urlString: product.photoUrl)
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
            make.edges.equalTo(self)
        }
        productImageView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints{ (make) in
            make.bottom.equalTo(productImageView).inset(10)
            make.left.right.lessThanOrEqualTo(productImageView)
            make.height.equalTo(25)
        }
    }
    
    var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.randevoo.mainLight.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainLight
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let priceLabel: UILabel = {
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
