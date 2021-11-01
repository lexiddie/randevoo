//
//  ReservedProductCell.swift
//  randevoo
//
//  Created by Lex on 7/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class ReservedProductCell: UICollectionViewCell {
    
    var reservationStatus = ""
    var reserveState: String? {
        didSet {
            guard let reserve = reserveState else { return }
            reservationStatus = reserve
        }
    }
    
    var product: Product? {
        didSet {
            guard let product = product else { return }
            let photoUrl = product.photoUrls[0]
            let name = product.name
            let color = product.variants[0].color
            let size = product.variants[0].size
            let quantity = product.variants[0].quantity
            productImageView.loadCacheImage(urlString: photoUrl)
            nameLabel.text = name
            colorLabel.text = "Color: \(String(color!))"
            sizeLabel.text = "Size: \(String(size!))"
            quantityLabel.text = "x \(String(quantity!))"
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let priceFormat = numberFormatter.string(from: NSNumber(value: calculatedPrice(product: product)))
            priceLabel.text = "Total: ฿\(String(priceFormat!))"
            if (product.isBanned || !product.isActive) && reservationStatus != "Completed"{
                if product.isBanned {
                    background.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                    isBannedLabel.text = "Product is currently Banned!"
                    isBannedLabel.textColor = UIColor.randevoo.mainRed.withAlphaComponent(0.8)
                    isBannedLabel.backgroundColor = UIColor.white
                } else if !product.isActive && reservationStatus != "Approved" {
                    background.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                    isBannedLabel.text = "Product is currently Removed!"
                    isBannedLabel.textColor = UIColor.randevoo.mainRed.withAlphaComponent(0.8)
                    isBannedLabel.backgroundColor = UIColor.white
                }
            } else {
                background.backgroundColor = .clear
                isBannedLabel.text = ""
                isBannedLabel.backgroundColor = .clear
            }
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
    
    private func calculatedPrice(product: Product) -> Double {
        var amount: Double = 0.0
        for i in product.variants {
            amount += (Double(i.quantity)) * product.price
        }
        return amount
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(productImageView)
        productImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(self.frame.height - 20)
            make.width.equalTo(self.frame.width / 3)
            make.left.equalTo(self).inset(10)
        }
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(colorLabel)
        contentStackView.addArrangedSubview(sizeLabel)
        contentStackView.addArrangedSubview(quantityLabel)
        contentStackView.addArrangedSubview(priceLabel)
        contentStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(self.frame.height - 20)
            make.width.equalTo((self.frame.width - (self.frame.width / 3)) - 20)
            make.right.equalTo(self).inset(10)
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
    
    let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let nameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let colorLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let sizeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let quantityLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let priceLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
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
}
