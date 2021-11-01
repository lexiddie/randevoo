//
//  CurrencyCell.swift
//  randevoo
//
//  Created by Lex on 19/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class CurrencyCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupNameLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private func setupUI() {
        addSubview(cellView)
        cellView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self).inset(5)
            make.left.right.equalTo(self).inset(8)
        }
    }
    
    private func setupNameLabel() {
        cellView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.right.lessThanOrEqualTo(cellView).inset(8)
            make.centerY.centerX.equalTo(cellView)
        }
    }
}
