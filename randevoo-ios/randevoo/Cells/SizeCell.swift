//
//  PriceCell.swift
//  randevoo
//
//  Created by Xell on 29/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class SizeCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.randevoo.mainLight
        addSubview(background)
        background.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(15)
            make.bottom.equalTo(self).inset(15)
            make.left.lessThanOrEqualTo(self).offset(5)
            make.right.equalTo(self).inset(5)
        }
        background.addSubview(sizeLabel)
        sizeLabel.snp.makeConstraints { (make) in
            make.center.equalTo(background)
        }
        background.addSubview(overLayBackground)
        overLayBackground.snp.makeConstraints { (make) in
            make.edges.equalTo(background)
        }
        background.addSubview(disableView)
        disableView.snp.makeConstraints { (make) in
            make.edges.equalTo(background)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let background: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        view.layer.masksToBounds = false
        return view
    }()
    
    let sizeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let overLayBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    
    let disableView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
}
