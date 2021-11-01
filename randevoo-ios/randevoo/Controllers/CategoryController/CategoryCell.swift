//
//  CategoryCell.swift
//  randevoo
//
//  Created by Lex on 7/9/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class CategoryCell: UICollectionViewCell {
    
    var category: Category? {
        didSet {
            guard let category = category else { return }
            nameLabel.text = category.name
            
            if category.isSelected {
                nameLabel.font = UIFont(name:"Quicksand-Bold", size: 17)
                nameLabel.textColor = UIColor.randevoo.mainBlack
            } else {
                nameLabel.font = UIFont(name: "Quicksand-Regular", size: 17)
                nameLabel.textColor = UIColor.randevoo.mainGray
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
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    let nameLabel: UILabel = {
        let label = PaddingLabel()
        label.textColor = UIColor.randevoo.mainBlack
        label.layer.backgroundColor = UIColor.white.withAlphaComponent(0.95).cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 10, 0, 10)
        return label
    }()
}
