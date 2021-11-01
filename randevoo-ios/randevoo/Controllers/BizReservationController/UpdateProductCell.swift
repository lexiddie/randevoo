//
//  UpdateProductCell.swift
//  randevoo
//
//  Created by Lex on 30/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

protocol UpdateProductCellDelegate {
    func onChangeVariant(delegatedFrom cell: UpdateProductCell, variants: [Variant])
}

class UpdateProductCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UpdateQuantityCellDelegate {
    
    let updateQuantityCell  = "updateQuantityCell"
    
    var variants: [Variant] = []
    
    var delegate: UpdateProductCellDelegate?
    
    var product: Product? {
        didSet {
            guard let product = product else { return }
            
            variants = product.variants
            
            productImageView.loadCacheImage(urlString: product.photoUrls[0])
            nameLabel.text = product.name
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let priceFormat = numberFormatter.string(from: NSNumber(value: product.price))
            priceLabel.text = "฿\(String(priceFormat!))"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        initiateCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(productImageView)
        productImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.centerX.equalTo(self)
            make.height.equalTo(self.frame.width)
        }
        productImageView.addSubview(productStackView)
        productStackView.snp.makeConstraints { (make) in
            make.centerX.equalTo(productImageView)
            make.height.equalTo(62)
            make.left.right.lessThanOrEqualTo(productImageView)
            make.bottom.equalTo(productImageView)
        }
        productStackView.addArrangedSubview(nameLabel)
        productStackView.addArrangedSubview(priceLabel)
        nameLabel.snp.makeConstraints{ (make) in
            make.height.equalTo(30)
        }
        priceLabel.snp.makeConstraints{ (make) in
            make.height.equalTo(30)
        }
        addSubview(quantityCollectionView)
        quantityCollectionView.snp.makeConstraints{ (make) in
            make.top.equalTo(productImageView.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.bottom.equalTo(self)
        }
    }
    
    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 0
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.randevoo.mainLight.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainLight
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let productStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.spacing = 2
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let nameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.layer.backgroundColor = UIColor.white.withAlphaComponent(0.95).cgColor
        label.layer.cornerRadius = 5
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 10, 0, 10)
        return label
    }()
    
    let priceLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.layer.backgroundColor = UIColor.white.withAlphaComponent(0.95).cgColor
        label.layer.cornerRadius = 5
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 10, 0, 10)
        return label
    }()
    
    lazy var quantityCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private func initiateCollectionView() {
        quantityCollectionView.delegate = self
        quantityCollectionView.dataSource = self
        quantityCollectionView.register(UpdateQuantityCell.self, forCellWithReuseIdentifier: updateQuantityCell)
    }
    
}

extension UpdateProductCell {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.frame.width
        return CGSize(width: width, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return variants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: updateQuantityCell, for: indexPath) as! UpdateQuantityCell
        cell.variant = variants[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: UpdateQuantityCell) {
        guard let indexPath = quantityCollectionView.indexPath(for: cell) else { return }
        let quantity = variants[indexPath.row].quantity
        let available = variants[indexPath.row].available
        let minimum = quantity! - available!
        let maximum: Int = 100
        let text = String(cell.numberTextField.text!)
        let number = Int(text)
        if number != nil && number! >= minimum && number! <= maximum {
            variants[indexPath.row].quantity = number!
            delegate?.onChangeVariant(delegatedFrom: self, variants: variants)
        }
    }
    
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: UpdateQuantityCell) -> Bool {
        return true
    }
    
    func plusAmount(delegatedFrom cell: UpdateQuantityCell) -> Int {
        guard let indexPath = quantityCollectionView.indexPath(for: cell) else { return 0 }
        let quantity = variants[indexPath.row].quantity
        var current: Int = quantity!
        let maximum: Int = 100
        if current < maximum {
            current += 1
            variants[indexPath.row].quantity = current
            delegate?.onChangeVariant(delegatedFrom: self, variants: variants)
        }
        return current
    }
    
    func minusAmount(delegatedFrom cell: UpdateQuantityCell) -> Int {
        guard let indexPath = quantityCollectionView.indexPath(for: cell) else { return 0 }
        let quantity = variants[indexPath.row].quantity
        let available = variants[indexPath.row].available
        let minimum = quantity! - available!
        var current: Int = quantity!
        if current > minimum {
            current -= 1
            variants[indexPath.row].quantity = current
            delegate?.onChangeVariant(delegatedFrom: self, variants: variants)
        }
        return current
    }
}
