//
//  CreateBizNameView.swift
//  randevoo
//
//  Created by Lex on 30/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class CreateBizNameView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(businessNameLabel)
        businessNameLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(50)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(businessNameTextField)
        businessNameTextField.snp.makeConstraints{ (make) in
            make.top.equalTo(businessNameLabel.snp.bottom).offset(20)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
        }
        addSubview(nextButton)
        nextButton.snp.makeConstraints{ (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
        }
    }
    
    let businessNameLabel: UILabel = {
        let label = UILabel()
        label.text = "What is your business name?"
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let businessNameTextField: UITextField = {
        let textField = UITextField(placeholder: "Business name", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .default, autoCorrectionType: .yes, autoCapitalizationType: .words)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.randevoo.mainColor
        return textField
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 16)
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.setTitle("Next", for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.randevoo.mainColor
        button.addTarget(self, action: #selector(CreateBizNameController.handleNext(_:)), for: .touchUpInside)
        return button
    }()

}
