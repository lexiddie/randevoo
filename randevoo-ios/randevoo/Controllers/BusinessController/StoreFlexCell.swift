//
//  StoreFlexCell.swift
//  randevoo
//
//  Created by Lex on 27/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class StoreFlexCell: UICollectionViewCell {
    
    var store: Store? {
        didSet {
            guard let store = store else { return }
            usernameLabel.text = store.username
            nameLabel.text = store.name
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
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(storeStackView)
        storeStackView.addArrangedSubview(storeImageView)
        storeStackView.addArrangedSubview(infoStackView)
        storeStackView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(60)
        }
        storeImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(storeStackView)
            make.height.width.equalTo(60)
        }
        infoStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(storeStackView)
            make.height.equalTo(60)
            make.width.equalTo(self.frame.width - 90)
            make.right.equalTo(storeStackView)
        }
        infoStackView.addArrangedSubview(usernameLabel)
        infoStackView.addArrangedSubview(nameLabel)
    }
    
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
        imageView.layer.cornerRadius = 60/2
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.randevoo.mainWhiteGray.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainWhiteGray
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let usernameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(10, 5, 0, 5)
        return label
    }()
    
    let nameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainGray
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 10, 5)
        return label
    }()
}
