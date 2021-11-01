//
//  NotificationsView.swift
//  randevoo
//
//  Created by Lex on 15/8/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit

class NotificationsView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.white
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
    
    let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        table.allowsSelection = true
        return table
    }()
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Chat is Empty"
        label.textColor = UIColor.randevoo.mainBlueGrey
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
}
