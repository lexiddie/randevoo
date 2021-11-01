//
//  EditUsernameView.swift
//  randevoo
//
//  Created by Alexander on 11/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class EditUsernameView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(30)
        }
        addSubview(usernameTextField)
        usernameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(usernameLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(30)
        }
        addSubview(endLineView)
        endLineView.snp.makeConstraints { (make) in
            make.top.equalTo(usernameTextField.snp.bottom)
            make.height.equalTo(0.5)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
        }
    }
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textAlignment = .left
        return label
    }()
    
    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Quicksand-Medium", size: 17)
        textField.textColor = UIColor.randevoo.mainBlack
        textField.textAlignment = .left
        textField.backgroundColor = UIColor.clear
        textField.autocorrectionType = .no
        textField.borderStyle = UITextField.BorderStyle.none
        textField.isEnabled = true
        textField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        return textField
    }()
    
    let endLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()

}
