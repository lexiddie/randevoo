//
//  FooterButtonCell.swift
//  randevoo
//
//  Created by Xell on 5/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

protocol AddProductDelegate  {
    func addProduct()
}

class FooterButtonCell: UICollectionViewCell {
    
    var delegate: AddProductDelegate?
    
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
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(addToListButton)
        addToListButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(5)
            make.left.right.lessThanOrEqualTo(self).inset(10)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).inset(20)
        }
    
    }
    
    lazy var addToListButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.randevoo.mainColor
        button.layer.cornerRadius = 5
        button.setTitle("Add to List", for: .normal)
        button.titleLabel?.font =  UIFont(name: "Quicksand-Regular", size: 20)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleAddProduct(_:)), for: .touchUpInside)
        return button
    }()
    
    @IBAction func handleAddProduct(_ sender: Any?) {
        delegate?.addProduct()
    }
    
}
