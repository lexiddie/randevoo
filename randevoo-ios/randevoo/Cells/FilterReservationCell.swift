//
//  FilterReservationCell.swift
//  randevoo
//
//  Created by Xell on 28/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class FilterReservationCell: UICollectionViewCell {
    
    var title: String? {
        didSet {
            guard let currentTitle = title else { return }
            titleLabel.text = currentTitle
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.randevoo.mainLight
        setupUI()
    }
    
    private func setupUI(){
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self).offset(20)
            make.width.equalTo(self.frame.width - 20)
            make.centerY.equalTo(self)
        }
        addSubview(indicateImageView)
        indicateImageView.snp.makeConstraints { (make) in
            make.right.equalTo(self).inset(20)
            make.centerY.equalTo(self)
            make.width.height.equalTo(20)
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 16)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    var indicateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
}
