//
//  CreateBizAccountView.swift
//  randevoo
//
//  Created by Lex on 30/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class CreateBizAccountView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(scrollView)
        scrollView.contentSize = CGSize(width: self.frame.width, height: 530)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.safeAreaLayoutGuide)
        }
        scrollView.addSubview(businessTypeLabel)
        businessTypeLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(scrollView).inset(50)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        scrollView.addSubview(businessTypeDetailLabel)
        businessTypeDetailLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(businessTypeLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(60)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        scrollView.addSubview(businessTypeTextField)
        businessTypeTextField.snp.makeConstraints{ (make) in
            make.top.equalTo(businessTypeDetailLabel.snp.bottom).offset(15)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        scrollView.addSubview(businessTypeButton)
        businessTypeButton.snp.makeConstraints{ (make) in
            make.top.equalTo(businessTypeDetailLabel.snp.bottom).offset(15)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        scrollView.addSubview(aboutLabel)
        aboutLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(businessTypeTextField.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        scrollView.addSubview(aboutOptionalLabel)
        aboutOptionalLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(businessTypeTextField.snp.bottom).offset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        scrollView.addSubview(aboutDetailLabel)
        aboutDetailLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(aboutLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        scrollView.addSubview(aboutTextView)
        aboutTextView.snp.makeConstraints{ (make) in
            make.top.equalTo(aboutDetailLabel.snp.bottom).offset(15)
            make.centerX.equalTo(self)
            make.height.equalTo(200)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(createButton)
        createButton.snp.makeConstraints{ (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
        }
    }
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    let businessTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Select your business type"
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let businessTypeDetailLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose a type that best describe your business. You also have an option for display or hide in your profile."
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 3
        return label
    }()
    
    let businessTypeTextField: UITextField = {
        let textField = UITextField(placeholder: "Search type", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .default, autoCorrectionType: .yes, autoCapitalizationType: .words)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.randevoo.mainColor
        textField.isEnabled = false
        return textField
    }()
    
    let businessTypeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(CreateBizAccountController.handleSearchType(_:)), for: .touchUpInside)
        return button
    }()
    
    let aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "Describe your business"
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let aboutOptionalLabel: UILabel = {
        let label = UILabel()
        label.text = "Optional"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.textAlignment = .right
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    let aboutDetailLabel: UILabel = {
        let label = UILabel()
        label.text = "What makes your business special? \nDon't think too hard, just have fun with it."
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let aboutTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.8)
        textView.text = "A little description about your business"
        textView.font = UIFont(name: "Quicksand-Regular", size: 16)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.randevoo.mainColor.cgColor
        textView.backgroundColor = UIColor.randevoo.mainColor
        textView.isScrollEnabled = true
        return textView
    }()
    
    let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 16)
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.setTitle("Create", for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.randevoo.mainColor
        button.addTarget(self, action: #selector(CreateBizAccountController.handleCreate(_:)), for: .touchUpInside)
        return button
    }()
}
