//
//  ColorCell.swift
//  randevoo
//
//  Created by Xell on 29/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.randevoo.mainLight
        addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.bottom.equalTo(self).inset(10)
            make.left.lessThanOrEqualTo(self).offset(5)
            make.right.equalTo(self).inset(5)
        }
        mainView.addSubview(colorIndicator)
        colorIndicator.snp.makeConstraints { (make) in
            make.top.equalTo(mainView).offset(5)
            make.left.lessThanOrEqualTo(mainView).offset(10)
            make.bottom.equalTo(mainView).inset(5)
            make.width.height.equalTo(20)
        }
        mainView.addSubview(colorLabel)
        colorLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(mainView)
            make.left.lessThanOrEqualTo(colorIndicator.snp.right).offset(3)
        }
        mainView.addSubview(disableView)
        disableView.snp.makeConstraints { (make) in
            make.edges.equalTo(mainView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyan
        view.layer.cornerRadius = 6
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        view.layer.masksToBounds = false
        return view
    }()
    
    var colorIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyan
        view.layer.cornerRadius = 3
        view.layer.borderWidth = 0
        return view
    }()
    
    let colorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let disableView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()

}
