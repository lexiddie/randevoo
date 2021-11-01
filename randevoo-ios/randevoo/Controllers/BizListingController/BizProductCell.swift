//
//  BizProductCell.swift
//  randevoo
//
//  Created by Lex on 16/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

protocol BizProductCellDelegate {
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: BizProductCell)
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: BizProductCell)  -> Bool
    func plusAmount(delegatedFrom cell: BizProductCell) -> Int
    func minusAmount(delegatedFrom cell: BizProductCell) -> Int
    func deleteVariation(delegatedFrom cell: BizProductCell)
}

class BizProductCell: UICollectionViewCell {
    
    var minimum: Int = 0
    var maximum: Int = 100

    var delegate: BizProductCellDelegate?
    
    var variant: Variant? {
        didSet {
            guard let variant = variant else { return }

            let color = variant.color!
            let size = variant.size!
            let quantity = variant.quantity!
            let reserve = variant.reserve!
            
            minimum = reserve
            
            colorLabel.text = "Color: \(String(color))"
            sizeLabel.text = "Size: \(String(size))"
            quantityLabel.text = "Quantity: \(String(quantity))"
            reserveLabel.text = "Reserve: \(String(reserve))"
            numberTextField.text = String(quantity)
        }
    }
    
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
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self).inset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.center.equalTo(self)
        }
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.right.equalTo(self).inset(10)
            make.width.height.equalTo(35)
        }
        mainView.addSubview(actionStackView)
        actionStackView.snp.makeConstraints { (make) in
            make.right.equalTo(mainView).inset(10)
            make.height.equalTo(40)
            make.width.equalTo(180)
            make.centerY.equalTo(mainView)
        }
        mainView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { (make) in
            make.left.equalTo(mainView).inset(10)
            make.right.equalTo(actionStackView.snp.left).offset(-10)
            make.height.equalTo(100)
            make.centerY.equalTo(mainView)
        }
        infoStackView.addArrangedSubview(colorLabel)
        infoStackView.addArrangedSubview(sizeLabel)
        infoStackView.addArrangedSubview(quantityLabel)
        infoStackView.addArrangedSubview(reserveLabel)
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
    
    let mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.randevoo.mainColor
        return view
    }()
    
    let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = UIColor.randevoo.mainColor
        stackView.layer.cornerRadius = 5
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let colorLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(10, 5, 0, 5)
        return label
    }()
    
    let sizeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let quantityLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    let reserveLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 10, 5)
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
    
    @IBAction func handlePlus(_ Sender: Any?) {
        let amount = delegate?.plusAmount(delegatedFrom: self)
        if amount! < maximum {
            numberTextField.text = String(amount!)
            quantityLabel.text = "Quantity: \(String(amount!))"
            minusButton.isEnabled = true
            minusButton.tintColor = UIColor.black
        } else if numberTextField.text == "" && amount! < maximum {
            numberTextField.text = String(1)
            quantityLabel.text = "Quantity: \(String(1))"
            minusButton.isEnabled = true
            minusButton.tintColor = UIColor.black
        } else if numberTextField.text == "" && amount! >= maximum {
            numberTextField.text = String(1)
            quantityLabel.text = "Quantity: \(String(1))"
            minusButton.isEnabled = false
            minusButton.tintColor = UIColor.gray
        } else if amount! >= maximum {
            numberTextField.text = String(amount!)
            quantityLabel.text = "Quantity: \(String(amount!))"
            minusButton.isEnabled = false
            minusButton.tintColor = UIColor.gray
        }
        plusButton.isEnabled = true
        plusButton.tintColor = UIColor.black
        
    }
    
    @IBAction func handleMinus(_ Sender: Any?) {
        let amount = delegate?.minusAmount(delegatedFrom: self)
        if amount! <= minimum {
            numberTextField.text = String(amount!)
            quantityLabel.text = "Quantity: \(String(amount!))"
            plusButton.isEnabled = false
            plusButton.tintColor = UIColor.lightGray
        } else if numberTextField.text == "" && amount! < minimum {
            numberTextField.text = String(1)
            quantityLabel.text = "Quantity: \(String(1))"
            plusButton.isEnabled = false
            plusButton.tintColor = UIColor.lightGray
        } else if amount! > minimum {
            numberTextField.text = String(amount!)
            quantityLabel.text = "Quantity: \(String(amount!))"
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
                quantityLabel.text = "Quantity: \(String(maximum))"
            } else if currentAmount < minimum {
                numberTextField.text = String(minimum)
                quantityLabel.text = "Quantity: \(String(minimum))"
            } else {
                quantityLabel.text = "Quantity: \(String(number))"
            }
        } else {
            numberTextField.text = String(1)
        }
        delegate?.collectionViewCell(valueChangedIn: numberTextField, delegatedFrom: self)
        
    }
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "DeleteIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleDelete(_:)), for: .touchUpInside)
        return button
    }()
    
    @IBAction func handleDelete(_ Sender: Any?) {
        delegate?.deleteVariation(delegatedFrom: self)
    }
}
