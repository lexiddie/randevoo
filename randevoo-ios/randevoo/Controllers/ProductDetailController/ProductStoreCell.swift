//
//  ProductStoreCell.swift
//  randevoo
//
//  Created by Xell on 8/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit
import SnapKit

class ProductStoreCell: UICollectionViewCell {
    
    var store: StoreAccount? {
        didSet {
            guard let store = store else { return }
            usernameLabel.text = store.username
            if store.profileUrl != "" {
                storeImageView.loadCacheImage(urlString: store.profileUrl)
            } else {
                storeImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
            }
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
    
    private func setupUI(){
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.height.equalTo(35)
            make.centerX.equalTo(self)
        }
        addSubview(storeStackView)
        storeStackView.addArrangedSubview(storeImageView)
        storeStackView.addArrangedSubview(usernameLabel)
        storeStackView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).inset(10)
        }
        storeImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(storeStackView)
            make.height.width.equalTo(50)
        }
        usernameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(storeStackView)
            make.height.equalTo(50)
            make.width.equalTo(self.frame.width - 100)
            make.right.equalTo(storeStackView).inset(20)
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Listed By"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let storeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.alignment = .leading
        return stackView
    }()
    
    let storeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 50/2
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.randevoo.mainWhiteGray.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainWhiteGray
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = PaddingLabel()
        label.textColor = UIColor.randevoo.mainColor
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 0
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 10, 0, 10)
        return label
    }()
}
