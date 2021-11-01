//
//  BizTimeslotCell.swift
//  randevoo
//
//  Created by Lex on 9/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class BizAvailable: Codable {
    var time: String! = ""
    var available: Int! = 0
    
    init(time: String, available: Int) {
        self.time = time
        self.available = available
    }
}

class BizTimeslotCell: UICollectionViewCell {
    
    var time: BizAvailable? {
        didSet {
            guard let time = time else { return }
            timeLabel.text = time.time
            let number = time.available
            statusLabel.text = "\(String(number!)) Available"
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
        layer.cornerRadius = 10
        backgroundColor = UIColor.randevoo.mainLightGray
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(timeLabel)
        contentStackView.addArrangedSubview(statusLabel)
        contentStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.centerX.equalTo(contentStackView)
            make.height.equalTo(30)
            make.left.right.equalTo(contentStackView).inset(10)
        }
        statusLabel.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.left.equalTo(contentStackView).inset(10)
            make.right.lessThanOrEqualTo(contentStackView).inset(10)
            make.bottom.equalTo(self).inset(10)
        }
    }
    
    let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let timeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 0, 0, 0)
        return label
    }()
    
    let statusLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.randevoo.mainColor.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Medium", size: 18)
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 10, 0, 10)
        return label
    }()
}
