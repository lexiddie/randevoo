//
//  ProductTitleCell.swift
//  randevoo
//
//  Created by Xell on 8/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

protocol ProductTitleCellDelegate {
    func addToLikeList()
}

class ProductTitleCell: UICollectionViewCell {
    
    var delegate: ProductTitleCellDelegate?
    
    var product: Product? {
        didSet {
            guard let product = product else { return }
            nameLabel.text = product.name
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let priceFormat = numberFormatter.string(from: NSNumber(value: product.price))
            priceLabel.text = "฿\(String(priceFormat!))"
            let currentCategory = gSubcategories.filter({$0.id == product.subcategoryId})
            if currentCategory.count != 0 {
                categoryLabel.text = "Type: " + currentCategory[0].name
            } else {
                categoryLabel.text = "Type: Unset"
            }
            if !isPersonalAccount {
                favoriteButton.isHidden = true
            } else {
                favoriteButton.isHidden = false
            }
        }
    }
    
    var isSaved: Bool! {
        didSet {
            if isSaved {
                favoriteButton.setImage(UIImage.init(named: "LikedIcon"), for: .normal)
            } else {
                favoriteButton.setImage(UIImage.init(named: "LikeIcon"), for: .normal)
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
    
    private func setupUI(){
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.left.lessThanOrEqualTo(self).inset(20)
            make.right.equalTo(self).inset(70)
            make.centerX.equalTo(self)
        }
        addSubview(priceLabel)
        priceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
        }
        addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).inset(10)
        }
        addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.right.equalTo(self).inset(20)
            make.width.height.equalTo(30)
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name...."
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
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
        label.padding(0, 0, 0, 0)
        return label
    }()
    
    let categoryLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 0, 0, 0)
        return label
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let favorite = UIImage(named: "LikeIcon.png")
        button.isUserInteractionEnabled = true
        button.tintColor = UIColor.black
        button.setImage(favorite, for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action:#selector(handleFavorite(_:)), for: .touchUpInside)
        return button
    }()
    
    @IBAction func handleFavorite(_ sender: Any) {
        delegate?.addToLikeList()
    }

}
