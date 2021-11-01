//
//  CategoryFlexCell.swift
//  randevoo
//
//  Created by Lex on 6/9/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit

class CategoryFlexCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.bottom.centerX.centerY.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = PaddingLabel()
        label.textColor = UIColor.randevoo.mainBlack
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.borderColor = UIColor.randevoo.mainBlueGrey.cgColor
        label.layer.borderWidth = 1.0
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()

}
