//
//  FilterCategoryCell.swift
//  randevoo
//
//  Created by Xell on 17/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class FilterCategoryCell: UITableViewCell {
    
    var currentTitle: String? {
        didSet {
            guard let title = currentTitle else { return }
            type.text = title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(type)
        type.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.left.lessThanOrEqualTo(self).offset(20)
            make.centerY.equalTo(self)
        }
        addSubview(arrow)
        arrow.snp.makeConstraints { (make) in
            make.right.lessThanOrEqualTo(self).inset(20)
            make.centerY.equalTo(self)
            make.width.height.equalTo(20)
        }
        addSubview(seletedLabel)
        seletedLabel.snp.makeConstraints { (make) in
            make.right.equalTo(arrow.snp.left)
            make.centerY.equalTo(self)
            make.width.equalTo((self.frame.width / 2) - 20)
        }
        
    }
    
    let type: UILabel = {
        let label = UILabel()
        label.text = "N/A"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 18)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let seletedLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 18)
        label.textAlignment = .right
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let arrow: UIButton = {
        let button = UIButton(type: .system)
        let addImg = UIImage(named: "ArrowRight")
        button.setImage(addImg, for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = UIColor.randevoo.mainBlack
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        //    button.addTarget(self, action: #selector(ProductDetailController.handleAddToBag(_:)), for: .touchUpInside)
        return button
    }()
}
