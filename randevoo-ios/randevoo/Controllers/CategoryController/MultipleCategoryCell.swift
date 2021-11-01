//
//  MultipleCategoryCell.swift
//  randevoo
//
//  Created by Lex on 21/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class MultipleCategoryCell: UICollectionViewCell {
    
    var category: Category? {
        didSet {
            guard let category = category else { return }
            nameLabel.text = category.name
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
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 10, 0, 10)
        return label
    }()
}
