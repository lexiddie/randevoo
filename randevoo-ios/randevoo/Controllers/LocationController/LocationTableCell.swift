//
//  LocationTableCell.swift
//  randevoo
//
//  Created by Lex on 1/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class LocationTableCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints{ (make) in
            make.top.bottom.centerX.centerY.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
}
