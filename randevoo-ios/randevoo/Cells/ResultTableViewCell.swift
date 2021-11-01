//
//  ResultTableViewCell.swift
//  randevoo
//
//  Created by Xell on 25/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
   
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
        addSubview(HistoryLabel)
        HistoryLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
        }
        addSubview(removeButton)
        removeButton.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.centerY.equalTo(self)
        }
        
    }
    
    let HistoryLabel: UILabel = {
        let label = UILabel()
        label.text = "1. "
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Remove", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainRed, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 15)
        return button
    }()
    
}
