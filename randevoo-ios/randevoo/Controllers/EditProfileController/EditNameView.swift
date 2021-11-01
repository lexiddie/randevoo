//
//  EditNameView.swift
//  randevoo
//
//  Created by Alexander on 11/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class EditNameView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(10)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(30)
        }
        addSubview(nameTextField)
        nameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(30)
        }
        addSubview(endLineView)
        endLineView.snp.makeConstraints { (make) in
            make.top.equalTo(nameTextField.snp.bottom)
            make.height.equalTo(0.5)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textAlignment = .left
        return label
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Quicksand-Medium", size: 17)
        textField.textColor = UIColor.randevoo.mainBlack
        textField.textAlignment = .left
        textField.backgroundColor = UIColor.clear
        textField.autocorrectionType = .no
        textField.borderStyle = UITextField.BorderStyle.none
        textField.isEnabled = true
        textField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        return textField
    }()
    
    let endLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()

}
