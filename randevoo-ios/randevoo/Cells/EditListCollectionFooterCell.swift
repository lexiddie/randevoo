//
//  EditListCollectionFooterCell.swift
//  randevoo
//
//  Created by Xell on 6/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

protocol EditListTextDelegate {
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: EditListCollectionFooterCell)
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: EditListCollectionFooterCell)  -> Bool
    func increaseAmount() -> Int
    func decreaseAmount() -> Int
}

class EditListCollectionFooterCell:  UICollectionViewCell {
    
    var delegate: EditListTextDelegate?
    var controller: UIViewController!
    var maximum = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.randevoo.mainLight
        numberTextField.delegate = self
        setupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enableIncreaseDecrease() {
        if maximum == 0 {
            increaseButton.isEnabled = false
            decreaseButton.isEnabled = false
            numberTextField.isEnabled = false
        } else {
            increaseButton.isEnabled = true
            decreaseButton.isEnabled = true
            numberTextField.isEnabled = true
        }
    }
    
    private func setupUI(){
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.left.equalTo(self).offset(10)
        }
        addSubview(decreaseBackground)
        decreaseBackground.snp.makeConstraints{ (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.width.height.equalTo(40)
        }
        addSubview(textFieldBackground)
        textFieldBackground.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.lessThanOrEqualTo(decreaseBackground.snp.right).offset(10)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
        addSubview(increaseBackground)
        increaseBackground.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.lessThanOrEqualTo(textFieldBackground.snp.right).offset(10)
            make.width.height.equalTo(40)
        }
        decreaseBackground.addSubview(decreaseButton)
        decreaseButton.snp.makeConstraints { (make) in
            make.edges.equalTo(decreaseBackground)
        }
        textFieldBackground.addSubview(numberTextField)
        numberTextField.snp.makeConstraints { (make) in
            make.edges.equalTo(textFieldBackground)
        }
        increaseBackground.addSubview(increaseButton)
        increaseButton.snp.makeConstraints { (make) in
            make.edges.equalTo(increaseBackground)
        }
    }
    
    var decreaseBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyan
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.1
        view.layer.masksToBounds = false
        return view
    }()
    
    var textFieldBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyan
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.1
        view.layer.masksToBounds = false
        return view
    }()
    
    var increaseBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyan
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.1
        view.layer.masksToBounds = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Amount"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    lazy var numberTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.text = "1"
        textField.backgroundColor = UIColor.white
        textField.layer.borderColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.5).cgColor
        textField.font = UIFont(name: "Quicksand-Regular", size: 15)
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.addTarget(self, action: #selector(valuedChanged(_:)), for: .editingChanged)
        textField.keyboardType = .numberPad
        return textField
    }()
    
    lazy var increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.setTitle("+", for: .normal)
        button.tintColor = UIColor.black
        button.titleLabel?.font =  UIFont(name: "Quicksand-Meduim", size: 20)
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.5).cgColor
        button.addTarget(self, action: #selector(increaseAmount(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.setTitle("-", for: .normal)
        button.tintColor = UIColor.black
        button.titleLabel?.font =  UIFont(name: "Quicksand-Meduim", size: 20)
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.5).cgColor
        button.addTarget(self, action: #selector(decreaseAmount(_:)), for: .touchUpInside)
        return button
    }()
    
    @IBAction func increaseAmount(_ Sender: Any?) {
        let amount = delegate?.increaseAmount()
        if amount! < maximum {
            numberTextField.text = String(amount!)
            increaseButton.isEnabled = true
            increaseButton.tintColor = UIColor.black
        } else if numberTextField.text == "" && amount! < maximum {
            numberTextField.text = String(1)
            increaseButton.isEnabled = true
            increaseButton.tintColor = UIColor.black
        }else if numberTextField.text == "" && amount! >= maximum {
            numberTextField.text = String(1)
            increaseButton.isEnabled = false
            increaseButton.tintColor = UIColor.gray
        }else if amount! >= maximum{
            numberTextField.text = String(amount!)
            increaseButton.isEnabled = false
            increaseButton.tintColor = UIColor.gray
        }
        decreaseButton.isEnabled = true
        decreaseButton.tintColor = UIColor.black
        
    }
    
    @IBAction func decreaseAmount(_ Sender: Any?) {
        let amount = delegate?.decreaseAmount()
        if amount! <= 1 {
            decreaseButton.isEnabled = false
            decreaseButton.tintColor = UIColor.lightGray
            numberTextField.text = String(amount!)
        }else if numberTextField.text == "" && amount! < 1 {
            numberTextField.text = String(1)
            decreaseButton.isEnabled = false
            decreaseButton.tintColor = UIColor.lightGray
        }else if amount! > 1 {
            numberTextField.text = String(amount!)
        }
        increaseButton.isEnabled = true
        increaseButton.tintColor = UIColor.black
    }
    
    @IBAction func valuedChanged(_ sender: Any?) {
        let number = String(numberTextField.text!)
        if number != "" {
            let currentAmount = Int(number)!
            if currentAmount > maximum {
                numberTextField.text = String(maximum)
            }
        } else {
            numberTextField.text = String("")
        }
        delegate?.collectionViewCell(valueChangedIn: numberTextField, delegatedFrom: self)
        
    }
    
}

extension EditListCollectionFooterCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let delegate = delegate {
            return delegate.collectionViewCell(textField: textField, shouldChangeCharactersIn: range, replacementString: string, delegatedFrom: self)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("run this")
        let mainController = controller as! EditListController
        if textField.text == "" || textField.text == "0" {
            textField.text = "1"
            mainController.amount = 1
        }
    }
}


