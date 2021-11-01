//
//  SearchResultCell.swift
//  randevoo
//
//  Created by Xell on 27/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(productName)
        productName.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.lessThanOrEqualTo(self).offset(10)
        }
    }
    
    let productName:UILabel = {
        let label = UILabel()
        label.text = "Bob"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
}
