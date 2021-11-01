//
//  ConditionCell.swift
//  randevoo
//
//  Created by Xell on 3/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class ConditionCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1, alpha: 0.1)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(background)
        background.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(40)
        }
        background.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(background)
        }
    }
    
    let background: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainLightGrey.withAlphaComponent(0.8)
        view.layer.cornerRadius = 5
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.text = ""
        label.textAlignment = .center
        return label
    }()
}
