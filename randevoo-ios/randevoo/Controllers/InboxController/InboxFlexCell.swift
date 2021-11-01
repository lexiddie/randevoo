//
//  InboxFlexCell.swift
//  randevoo
//
//  Created by Lex on 10/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class InboxFlexCell: UICollectionViewCell {
    
    var inboxPage: InboxPage? {
        didSet {
            guard let inboxPage = inboxPage else { return }
            
            nameLabel.text = inboxPage.label
            
            if inboxPage.isSelected {
                nameLabel.textColor = UIColor.randevoo.mainBlack
            } else {
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
        label.textColor =  UIColor.randevoo.mainGray
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 0
        label.font = UIFont(name: "Quicksand-Bold", size: 16)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 3, 0, 3)
        return label
    }()
}
