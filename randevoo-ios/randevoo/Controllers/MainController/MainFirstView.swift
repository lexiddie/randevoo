//
//  MainFirst.swift
//  randevoo
//
//  Created by Lex on 6/12/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class MainFirstView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        addSubview(mainImageView)
        mainImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.centerX.equalTo(self)
            make.width.height.equalTo(self.frame.width - 40)
        }
        addSubview(introLabel)
        introLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(mainImageView.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(introLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
    }
    
    let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MainFirst")!.withRenderingMode(.alwaysOriginal)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let introLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover"
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.text = "Explore exclusive and hidden treasures"
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
}
