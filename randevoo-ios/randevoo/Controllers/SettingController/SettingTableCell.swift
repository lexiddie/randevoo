//
//  SettingFlexCell.swift
//  randevoo
//
//  Created by Lex on 23/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class SettingTableCell: UITableViewCell {
    
    var snapSize: SnapSize? {
        didSet {
            autoRenderRadius(snapSize: snapSize!)
        }
    }
    
    var setting: Setting? {
        didSet {
            nameLabel.text = setting?.child.rawValue
            if setting?.parent == .action && setting?.child == .signOut {
                nameLabel.textColor = UIColor.randevoo.mainRed
                nameLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundView?.backgroundColor = UIColor.clear
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        separatorInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 20)
        addSubview(currentView)
        currentView.snp.makeConstraints { (make) in
            make.top.bottom.centerX.centerY.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(20)
        }
        currentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints{ (make) in
            make.top.bottom.centerX.centerY.equalTo(currentView)
            make.left.right.lessThanOrEqualTo(currentView).inset(20)
        }
    }
    
    private func autoRenderRadius(snapSize: SnapSize) {
        if snapSize.totalList - 1 == 0 {
            separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
            currentView.layer.cornerRadius = 10
            currentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if snapSize.currentIndex == 0 {
            currentView.layer.cornerRadius = 10
            currentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else if snapSize.totalList - 1 == snapSize.currentIndex {
            separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
            currentView.layer.cornerRadius = 10
            currentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    let currentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 17)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
}
