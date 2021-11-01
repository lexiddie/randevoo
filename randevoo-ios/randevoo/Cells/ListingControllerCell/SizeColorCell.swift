//
//  SizeColorCell.swift
//  randevoo
//
//  Created by Xell on 5/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

protocol RemoveSizeColorDelegate {
    func removeCell(sizeColorCell: SizeColorCell)
}

class SizeColorCell: UICollectionViewCell {
    
    var delegate: RemoveSizeColorDelegate?
    
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
        addSubview(background)
        background.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.left.right.lessThanOrEqualTo(self).offset(5)
            make.bottom.equalTo(self).inset(5)
            make.center.equalTo(self)
        }
        background.addSubview(removeButton)
        removeButton.snp.makeConstraints { (make) in
            make.top.equalTo(background).offset(3)
            make.left.lessThanOrEqualTo(background).offset(3)
            make.width.height.equalTo(16)
        }
        background.addSubview(sizeLabel)
        sizeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(removeButton.snp.bottom)
            make.left.lessThanOrEqualTo(self).offset(20)
            make.right.equalTo(self).inset(3)
            make.height.equalTo(30)
        }
        background.addSubview(colorText)
        colorText.snp.makeConstraints { (make) in
            make.top.equalTo(sizeLabel.snp.bottom).offset(1)
            make.left.lessThanOrEqualTo(self).offset(20)
            make.height.equalTo(20)
            make.width.equalTo(40)
        }
        background.addSubview(colorLabel)
        colorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(sizeLabel.snp.bottom).offset(1)
            make.left.lessThanOrEqualTo(colorText.snp.right).offset(5)
            make.right.equalTo(self).inset(3)
        }
        background.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(colorText.snp.bottom).offset(1)
            make.left.lessThanOrEqualTo(self).offset(20)
            make.right.equalTo(self).inset(3)
            make.height.equalTo(30)
        }
    
    }
    
    let background: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainColor
        view.layer.cornerRadius = 6
        view.layer.borderColor =  UIColor.randevoo.mainLightGray.withAlphaComponent(0.5).cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    let sizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.text = "Size"
        label.textColor = UIColor.randevoo.mainLight
        label.textAlignment = .left
        return label
    }()
    
    let colorIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.layer.cornerRadius = 2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    let colorText: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.textAlignment = .left
        label.textColor = UIColor.randevoo.mainLight
        label.layer.cornerRadius = 2
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        label.layer.masksToBounds = true
        return label
    }()
    
    let colorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.text = "Size"
        label.textAlignment = .left
        label.textColor = UIColor.randevoo.mainLight
        return label
    }()
    
    let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.text = "Size"
        label.textAlignment = .left
        label.textColor = UIColor.randevoo.mainLight
        return label
    }()
    
    lazy var removeButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "DeleteIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleSelect(_:)), for: .touchUpInside)
        return button
    }()
    
    @IBAction func handleSelect(_ sender: Any?) {
        delegate?.removeCell(sizeColorCell: self)
    }
    
}
