//
//  ConfrimProductCell.swift
//  randevoo
//
//  Created by Xell on 21/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class ConfirmProductCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let textWidth = frame.width - 10
        addSubview(noLabel)
        noLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.left.lessThanOrEqualTo(self)
            make.centerY.equalTo(self)
        }
        addSubview(productName)
        productName.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.left.equalTo(noLabel.snp.right).offset(10)
            make.right.equalTo(self).inset(10)
            make.width.equalTo(textWidth)
            make.centerY.equalTo(self)
        }
        
    }
    
    let noLabel: UILabel = {
        let label = UILabel()
        label.text = "1. "
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let productName: UILabel = {
        let label = UILabel()
        label.text = "Air jordan 1"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    

}
