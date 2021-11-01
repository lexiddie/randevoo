//
//  IntroBizThirdView.swift
//  randevoo
//
//  Created by Lex on 29/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit

class IntroBizThirdView: UIView {

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
        addSubview(detailTextView)
        detailTextView.snp.makeConstraints{ (make) in
            make.top.equalTo(introLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(120)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
    }
    
    let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "IntroBizThird")!.withRenderingMode(.alwaysOriginal)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let introLabel: UILabel = {
        let label = UILabel()
        label.text = "Reach More People"
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let detailTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.randevoo.mainBlack
        textView.text = "With this platform, it helps your business grows. By Setting up your business information, address, and contact to comprehend related things of your business"
        textView.font = UIFont(name: "Quicksand-Regular", size: 17)
        textView.textAlignment = .center
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = UIColor.clear
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
}
