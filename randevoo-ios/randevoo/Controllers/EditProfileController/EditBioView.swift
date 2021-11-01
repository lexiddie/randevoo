//
//  EditBioView.swift
//  randevoo
//
//  Created by Alexander on 11/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class EditBioView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(bioLabel)
        bioLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(30)
        }
        addSubview(bioTextView)
        bioTextView.snp.makeConstraints { (make) in
            make.top.equalTo(bioLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(200)
            make.left.right.lessThanOrEqualTo(25)
        }
        addSubview(endLineView)
        endLineView.snp.makeConstraints { (make) in
            make.top.equalTo(bioTextView.snp.bottom)
            make.height.equalTo(0.5)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
        }
    }
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "Bio"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textAlignment = .left
        return label
    }()
    
    let bioTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.randevoo.mainBlack.withAlphaComponent(0.8)
        textView.text = "Bio"
        textView.font = UIFont(name: "Quicksand-Medium", size: 16)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.clear.cgColor
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = true
        return textView
    }()
    
    let endLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
}
