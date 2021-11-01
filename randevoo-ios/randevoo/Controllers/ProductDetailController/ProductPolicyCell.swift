//
//  ProductPolicyCell.swift
//  randevoo
//
//  Created by Lex on 3/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class ProductPolicyCell: UICollectionViewCell {
    
    var storeInfo: BizInfo? {
        didSet {
            guard let storeInfo = storeInfo else { return }
            if storeInfo.policy != "" {
                policyLabel.text = storeInfo.policy
            } else {
                policyLabel.text = "No policy to show"
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
    
    private func setupUI(){
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.height.equalTo(35)
            make.centerX.equalTo(self)
        }
        addSubview(policyLabel)
        policyLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.right.equalTo(self).inset(20)
            make.bottom.centerX.equalTo(self)
        }
    }
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Policy"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let policyLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 16)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        return label
    }()
}
