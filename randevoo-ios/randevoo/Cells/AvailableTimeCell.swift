//
//  AvailableTimeCell.swift
//  randevoo
//
//  Created by Xell on 18/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class AvailableTimeCell: UITableViewCell {

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
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.left.lessThanOrEqualTo(self).offset(20)
            make.centerY.equalTo(self)
        }
        addSubview(availableLabel)
        availableLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.right.lessThanOrEqualTo(self).inset(20)
            make.centerY.equalTo(self)
        }
        
    }
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "12:00-12:30"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let availableLabel: UILabel = {
        let label = UILabel()
        label.text = "Available"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()

}
