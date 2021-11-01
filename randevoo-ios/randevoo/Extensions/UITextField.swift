//
//  UITextField.swift
//  randevoo
//
//  Created by Lex on 18/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import Hex

extension UITextField {
    
    public convenience init(placeholder: String, placeholderColor: UIColor = UIColor.gray, keyboardType: UIKeyboardType = UIKeyboardType.default, autoCorrectionType: UITextAutocorrectionType = UITextAutocorrectionType.no, autoCapitalizationType: UITextAutocapitalizationType = UITextAutocapitalizationType.none) {
        self.init()
        self.keyboardType = keyboardType
        self.autocorrectionType = autoCorrectionType
        self.autocapitalizationType = autoCapitalizationType
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        self.font = UIFont(name: "Quicksand-Regular", size: 15)
        self.textColor = UIColor.randevoo.mainBlack
        self.backgroundColor = UIColor.randevoo.mainLight
        self.textAlignment = .left
        self.clearButtonMode = .whileEditing
        self.borderStyle = .none
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.randevoo.mainLightGrey.cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.rightView = paddingView
        self.leftViewMode = UITextField.ViewMode.always
        self.leftViewMode = UITextField.ViewMode.always
    }

}

