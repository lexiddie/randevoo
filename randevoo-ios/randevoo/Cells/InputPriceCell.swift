//
//  InputPriceCell.swift
//  randevoo
//
//  Created by Xell on 18/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

protocol InputPriceDelegate {
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: InputPriceCell)
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: InputPriceCell)  -> Bool
}

class InputPriceCell: UICollectionViewCell {
    
    var delegate: InputPriceDelegate?
    var price: Int? {
        didSet {
            guard let priceString = price else { return }
            print(priceString)
            if priceString != 0 {
                inputItem.text = String(priceString)
            } else {
                inputItem.text = ""
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputItem.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        let input = UITextField()
        input.placeholder = "Input Price"
        input.backgroundColor = UIColor.randevoo.mainLight
        input.layer.borderColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.5).cgColor
        input.font = UIFont(name: "Quicksand-Regular", size: 15)
        input.layer.borderWidth = 1
        input.layer.cornerRadius = 5
        input.keyboardType = .numberPad
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        input.leftView = paddingView
        input.rightView = paddingView
        input.leftViewMode = UITextField.ViewMode.always
        input.rightViewMode = UITextField.ViewMode.always
        input.addTarget(self, action: #selector(valuedChanged(_:)), for: .editingChanged)
        return input
    }()
    
    @IBAction func valuedChanged(_ sender: Any?) {
        delegate?.collectionViewCell(valueChangedIn: inputItem, delegatedFrom: self)
    }
    
}

extension InputPriceCell: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let delegate = delegate {
            return delegate.collectionViewCell(textField: textField, shouldChangeCharactersIn: range, replacementString: string, delegatedFrom: self)
        }
        return true
    }

}

