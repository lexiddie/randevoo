//
//  SearchCollectionCell.swift
//  randevoo
//
//  Created by Lex on 18/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import Hex

class SearchCollectionCell: UICollectionViewCell {
    
    var color: Color? {
        didSet {
            guard let color = color else { return }
            nameLabel.text = color.name
            productImageView.backgroundColor = UIColor(hex: color.code)
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
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(productImageView).inset(10)
            make.left.right.lessThanOrEqualTo(productImageView).inset(10)
            make.height.equalTo(30)
        }
    }
    
    var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        imageView.backgroundColor = UIColor.randevoo.mainLight
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = PaddingLabel()
        label.textColor = UIColor.randevoo.mainBlack
        label.layer.backgroundColor = UIColor.white.withAlphaComponent(0.95).cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 10, 0, 10)
        return label
    }()
}
