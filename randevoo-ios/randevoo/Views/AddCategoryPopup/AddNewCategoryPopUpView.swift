//
//  AddNewCategoryPopUpView.swift
//  randevoo
//
//  Created by Xell on 4/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class AddNewCategoryPopUpView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        self.backgroundColor = UIColor.white
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.centerX.equalTo(self)
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ADD TO LIKE"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
}
