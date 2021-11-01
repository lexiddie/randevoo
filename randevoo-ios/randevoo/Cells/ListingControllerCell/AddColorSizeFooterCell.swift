//
//  AddColorSizeFooterCell.swift
//  randevoo
//
//  Created by Xell on 6/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

protocol SizeColorCollectionCellDelegate {
    func addNewItemDescription()
}

class AddColorSizeFooterCell: UICollectionViewCell {
    
    var delegate: SizeColorCollectionCellDelegate?
    
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
        addSubview(addButton)
        addButton.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.height.equalTo(30)
        }
    }
    
    lazy var addButton: UIButton = {
        let imageView = UIImage.init(named: "AddingIcon")
        let button = UIButton(type: .system)
        button.setImage(imageView, for: .normal)
        button.setTitleColor(UIColor.randevoo.mainColor, for: .normal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor.randevoo.mainColor
        button.layer.cornerRadius = 15
        button.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        button.addTarget(self, action: #selector(handleAddNewItem(_:)), for: .touchUpInside)
        return button
    }()
    
    @IBAction func handleAddNewItem(_ sender: Any?) {
        delegate?.addNewItemDescription()
    }
    
}
 
