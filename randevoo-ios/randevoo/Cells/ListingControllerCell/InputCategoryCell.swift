//
//  InputCategoryCell.swift
//  randevoo
//
//  Created by Xell on 1/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class InputCategoryCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.randevoo.mainLight
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(inputTitle)
        inputTitle.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.height.equalTo(18)
        }
        addSubview(inputItem)
        inputItem.snp.makeConstraints { (make) in
            make.top.equalTo(inputTitle.snp.bottom).offset(5)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.bottom.equalTo(self)
            make.width.equalTo(self.frame.width - 20)
        }
    
    }
    
    let inputTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.text = "Price"
        label.textAlignment = .left
        return label
    }()
    
     lazy var inputItem: UITextField = {
        let input = UITextField(placeholder: "Select product category", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .phonePad, autoCorrectionType: .no, autoCapitalizationType: .none)
        input.backgroundColor = UIColor.randevoo.mainColor
        input.textColor = UIColor.white
        input.layer.borderColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.5).cgColor
        input.font = UIFont(name: "Quicksand-Regular", size: 15)
        input.layer.borderWidth = 1
        input.layer.cornerRadius = 5
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        input.leftView = paddingView
        input.rightView = paddingView
        input.leftViewMode = UITextField.ViewMode.always
        input.rightViewMode = UITextField.ViewMode.always
        return input
    }()
    
}
