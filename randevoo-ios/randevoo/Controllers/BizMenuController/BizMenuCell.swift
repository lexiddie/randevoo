//
//  BizMenuCell.swift
//  randevoo
//
//  Created by Lex on 28/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class BizMenuCell: UICollectionViewCell {
    
    var bizMenu: BizMenu? {
        didSet {
            guard let bizMenu = bizMenu else { return }
            menuImageView.image = bizMenu.iconPath
            nameLabel.text = bizMenu.name.rawValue
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
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(menuImageView)
        menuImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.width.equalTo(25)
            make.left.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(35)
            make.width.equalTo(self.frame.width - 95)
            make.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.width.equalTo(self.frame.width - 75)
            make.right.lessThanOrEqualTo(self)
            make.bottom.equalTo(self)
        }
    }
    
    let menuImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "DefaultPhoto")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 0
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = PaddingLabel()
        label.textColor = UIColor.randevoo.mainBlack
        label.layer.backgroundColor = UIColor.white.withAlphaComponent(0.95).cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 10, 0, 10)
        return label
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return view
    }()
}
