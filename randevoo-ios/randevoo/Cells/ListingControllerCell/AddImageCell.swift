//
//  AddImageCell.swift
//  randevoo
//
//  Created by Xell on 2/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit


protocol RemoveImageDelegate {
    func removeImageCell(imageCell: AddImageCell)
}

class AddImageCell: UICollectionViewCell {
    
    var delegate: RemoveImageDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1, alpha: 0.1)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(productImageView)
        productImageView.snp.makeConstraints { (make) in
            make.top.bottom.centerX.centerY.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
        }
        addSubview(removeButton)
        removeButton.snp.makeConstraints{ (make) in
            make.top.equalTo(productImageView).offset(3)
            make.left.equalTo(productImageView).inset(3)
            make.width.height.equalTo(20)
        }
    }
    
    lazy var removeButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "DeleteIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.tintColor = UIColor.randevoo.mainBlack
        button.addTarget(self, action: #selector(handleSelect(_:)), for: .touchUpInside)
        return button
    }()
    
    var productImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.randevoo.mainLightGrey.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainLight
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    @IBAction func handleSelect(_ sender: Any?) {
        delegate?.removeImageCell(imageCell: self)
    }
    
}
