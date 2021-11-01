//
//  ProductDescriptionCell.swift
//  randevoo
//
//  Created by Xell on 8/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class ProductDescriptionCell: UICollectionViewCell {
    
    var product: Product? {
        didSet {
            guard let product = product else { return }
            descriptionLabel.text = product.description
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
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.height.equalTo(35)
            make.centerX.equalTo(self)
        }
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.right.equalTo(self).inset(20)
            make.bottom.centerX.equalTo(self)
        }
    }
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 16)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        return label
    }()
}

