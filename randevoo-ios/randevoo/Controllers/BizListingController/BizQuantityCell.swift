//
//  BizQuantityCell.swift
//  randevoo
//
//  Created by Lex on 17/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

protocol BizQuantityCellDelegate {
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: BizQuantityCell)
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: BizQuantityCell)  -> Bool
    func plusAmount() -> Int
    func minusAmount() -> Int
}

class BizQuantityCell: UICollectionViewCell {
    
    var minimum: Int = 0
    var maximum: Int = 100

    var delegate: BizQuantityCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func calculatedPrice(product: Product) -> Double {
        var amount: Double = 0.0
        for i in product.variants {
            amount += (Double(i.quantity)) * product.price
        }
        return amount
    }
    
    private func setupUI() {
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(5)
            make.height.equalTo(35)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).offset(10)
        }
        addSubview(actionStackView)
        actionStackView.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(self).inset(20)
            make.height.equalTo(40)
            make.width.equalTo(180)
        }
        actionStackView.addArrangedSubview(minusBackground)
        actionStackView.addArrangedSubview(numberBackground)
        actionStackView.addArrangedSubview(plusBackground)
        minusBackground.snp.makeConstraints{ (make) in
            make.centerY.equalTo(actionStackView)
            make.width.height.equalTo(40)
        }
        numberBackground.snp.makeConstraints{ (make) in
            make.centerY.equalTo(actionStackView)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
        plusBackground.snp.makeConstraints{ (make) in
            make.centerY.equalTo(actionStackView)
            make.width.height.equalTo(40)
        }
        minusBackground.addSubview(plusButton)
        plusButton.snp.makeConstraints { (make) in
            make.edges.equalTo(minusBackground)
        }
        numberBackground.addSubview(numberTextField)
        numberTextField.snp.makeConstraints { (make) in
            make.edges.equalTo(numberBackground)
        }
        plusBackground.addSubview(minusButton)
        minusButton.snp.makeConstraints { (make) in
            make.edges.equalTo(plusBackground)
        }
    }
    
    let nameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "Quantity"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.alignment = .leading
        return stackView
    }()
    
    var numberBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.1
        view.layer.masksToBounds = false
        return view
    }()
    
    var minusBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.1
        view.layer.masksToBounds = false
        return view
    }()
    
    var plusBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.1
        view.layer.masksToBounds = false
        return view
    }()
    
    lazy var numberTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.text = "1"
        textField.backgroundColor = UIColor.white
        textField.layer.borderColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.5).cgColor
        textField.font = UIFont(name: "Quicksand-Medium", size: 16)
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.addTarget(self, action: #selector(valuedChanged(_:)), for: .editingChanged)
        textField.keyboardType = .numberPad
        textField.isSelected = false
        return textField
    }()
    
    lazy var minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "PlusIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handlePlus(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "MinusIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleMinus(_:)), for: .touchUpInside)
        return button
    }()
    
    @IBAction func handlePlus(_ Sender: Any?) {
        let amount = delegate?.plusAmount()
        if amount! < maximum {
            numberTextField.text = String(amount!)
            minusButton.isEnabled = true
            minusButton.tintColor = UIColor.black
        } else if numberTextField.text == "" && amount! < maximum {
            numberTextField.text = String(1)
            minusButton.isEnabled = true
            minusButton.tintColor = UIColor.black
        } else if numberTextField.text == "" && amount! >= maximum {
            numberTextField.text = String(1)
            minusButton.isEnabled = false
            minusButton.tintColor = UIColor.gray
        } else if amount! >= maximum {
            numberTextField.text = String(amount!)
            minusButton.isEnabled = false
            minusButton.tintColor = UIColor.gray
        }
        plusButton.isEnabled = true
        plusButton.tintColor = UIColor.black
        
    }
    
    @IBAction func handleMinus(_ Sender: Any?) {
        let amount = delegate?.minusAmount()
        if amount! <= minimum {
            numberTextField.text = String(amount!)
            plusButton.isEnabled = false
            plusButton.tintColor = UIColor.lightGray
        } else if numberTextField.text == "" && amount! < minimum {
            numberTextField.text = String(1)
            plusButton.isEnabled = false
            plusButton.tintColor = UIColor.lightGray
        } else if amount! > minimum {
            numberTextField.text = String(amount!)
        }
        minusButton.isEnabled = true
        minusButton.tintColor = UIColor.black
    }
    
    @IBAction func valuedChanged(_ sender: Any?) {
        let number = String(numberTextField.text!)
        if !number.isEmpty && number != "" {
            let currentAmount = Int(number)!
            if currentAmount > maximum {
                numberTextField.text = String(maximum)
            } else if currentAmount < minimum {
                numberTextField.text = String(minimum)
            } else {
            }
        } else {
            numberTextField.text = String(1)
        }
        delegate?.collectionViewCell(valueChangedIn: numberTextField, delegatedFrom: self)
        
    }
}
