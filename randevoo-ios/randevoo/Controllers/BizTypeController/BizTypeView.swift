//
//  BizTypeView.swift
//  randevoo
//
//  Created by Lex on 7/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class BizTypeView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(bizTypeTableView)
        bizTypeTableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    let bizTypeTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.randevoo.mainLight
        table.tableFooterView = UIView()
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        table.allowsSelection = true
        table.allowsSelectionDuringEditing = true
        return table
    }()
    
    let searchTextField: UITextField = {
        let textField = UITextField(placeholder: "Search types...", placeholderColor: UIColor.randevoo.mainGray, keyboardType: .default)
        textField.font = UIFont(name: "Quicksand-Bold", size: 17)
        textField.textColor = UIColor.randevoo.mainBlack
        textField.backgroundColor = UIColor.randevoo.mainGreyLight
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 0
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.isEnabled = true
        return textField
    }()
}
