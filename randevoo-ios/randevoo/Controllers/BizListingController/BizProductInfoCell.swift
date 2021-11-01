//
//  BizProductInfoCell.swift
//  randevoo
//
//  Created by Lex on 16/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

protocol BizProductInfoCellDelegate {
    func changeCategory(delegatedFrom cell: BizProductInfoCell)
//    func onChangeNameTextField(valueChangedIn textField: UITextField, delegatedFrom cell: BizProductInfoCell)
//    func onChangePriceTextField(valueChangedIn textField: UITextField, delegatedFrom cell: BizProductInfoCell)
    func onChangeName(record: String)
    func onChangePrice(record: String)
    func onChangeDescription(record: String)
}

class BizProductInfoCell: UICollectionViewCell, UITextViewDelegate {
    
    var delegate: BizProductInfoCellDelegate?
    
    var product: Product? {
        didSet {
            guard let product = product else { return }

//            let numberFormatter = NumberFormatter()
//            numberFormatter.numberStyle = .decimal
//            let priceFormat = numberFormatter.string(from: NSNumber(value: product.price))
    
            
//            let newDouble = product.price.format(f: ".2")

//            print("Cleaning", Double(newDouble)?.clean)
            
            categoryTextField.text = product.subcategory?.display()
            nameTextField.text = product.name
            priceTextField.text = String(product.price.format(f: ".2"))
            descriptionTextView.text = product.description
//            priceTextField.text = "฿\(String(priceFormat!))"
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
    
    // Height 245
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(self).inset(20)
            make.centerX.equalTo(self)
            make.height.equalTo(35)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(categoryTextField)
        categoryTextField.snp.makeConstraints{ (make) in
            make.top.equalTo(categoryLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(categoryButton)
        categoryButton.snp.makeConstraints{ (make) in
            make.top.equalTo(categoryLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(categoryTextField.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(35)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(nameTextField)
        nameTextField.snp.makeConstraints{ (make) in
            make.top.equalTo(nameLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(priceLabel)
        priceLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(nameTextField.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(35)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(priceTextField)
        priceTextField.snp.makeConstraints{ (make) in
            make.top.equalTo(priceLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(priceTextField.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(35)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints{ (make) in
            make.top.equalTo(descriptionLabel.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(200)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        addSubview(variantLabel)
        variantLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(35)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        descriptionTextView.delegate = self
    }
    
    let categoryLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "Category"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    lazy var categoryTextField: UITextField = {
        let textField = UITextField(placeholder: "Category", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .default, autoCorrectionType: .no, autoCapitalizationType: .none)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.randevoo.mainColor
        textField.font = UIFont(name: "Quicksand-Medium", size: 16)
        textField.isEnabled = false
        return textField
    }()
    
    let nameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "Name"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    lazy var nameTextField: UITextField = {
        let textField = UITextField(placeholder: "Name", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .default, autoCorrectionType: .no, autoCapitalizationType: .none)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.randevoo.mainColor
        textField.font = UIFont(name: "Quicksand-Medium", size: 16)
        textField.addTarget(self, action: #selector(nameOnChange(_:)), for: .editingChanged)
        textField.isEnabled = true
        return textField
    }()
    
    let priceLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "Price ฿"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    lazy var priceTextField: UITextField = {
        let textField = UITextField(placeholder: "Price", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .numberPad, autoCorrectionType: .no, autoCapitalizationType: .none)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.randevoo.mainColor
        textField.font = UIFont(name: "Quicksand-Medium", size: 16)
        textField.addTarget(self, action: #selector(priceOnChange(_:)), for: .editingChanged)
        textField.isEnabled = true
        return textField
    }()
    
    
    let descriptionLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "Description"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
//        textView.textColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.8)
        textView.textColor = UIColor.white
        textView.text = ""
        textView.font = UIFont(name: "Quicksand-Medium", size: 16)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.randevoo.mainColor.cgColor
        textView.backgroundColor = UIColor.randevoo.mainColor
        textView.isScrollEnabled = true
        return textView
    }()
    
    let variantLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "Variants"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    lazy var categoryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(handleCategory(_:)), for: .touchUpInside)
        return button
    }()
    
    @IBAction func handleCategory(_ Sender: Any?) {
        delegate?.changeCategory(delegatedFrom: self)
    }
    
    @IBAction func nameOnChange(_ sender: Any?) {
        var record = nameTextField.text! as String
        record = record.trimmingCharacters(in: .whitespacesAndNewlines)
        delegate?.onChangeName(record: record)
//        delegate?.onChangeNameTextField(valueChangedIn: nameTextField, delegatedFrom: self)
    }
    
    @IBAction func priceOnChange(_ sender: Any?) {
        var record = priceTextField.text! as String
        record = record.trimmingCharacters(in: .whitespacesAndNewlines)
        delegate?.onChangePrice(record: record)
//        delegate?.onChangePriceTextField(valueChangedIn: priceTextField, delegatedFrom: self)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard var record = textView.text else { return }
        record = record.trimmingCharacters(in: .whitespacesAndNewlines)
        delegate?.onChangeDescription(record: record)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard var record = textView.text else { return }
        record = record.trimmingCharacters(in: .whitespacesAndNewlines)
        delegate?.onChangeDescription(record: record)
//        if textView.text == "" {
//            textView.text = "Enter your description"
//            textView.textColor = UIColor.lightGray
//        } else {
//            delegate?.getTextView(text: textView.text)
//        }
    }
}
