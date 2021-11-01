//
//  SettingView.swift
//  randevoo
//
//  Created by Lex on 23/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class SettingView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLightGray
        addSubview(settingTableView)
        settingTableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.centerX.bottom.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
        }
    }
    
    let settingTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.randevoo.mainLightGray
        table.tableFooterView = UIView()
        table.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        table.allowsSelection = true
        table.allowsSelectionDuringEditing = true
        return table
    }()
}
