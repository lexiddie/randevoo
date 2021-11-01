//
//  DetailListFooterCell.swift
//  randevoo
//
//  Created by Xell on 15/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

protocol CheckAvailabilityDelegate {
    func selectAvailability(index: Int)
}

class DetailListFooterCell: UITableViewHeaderFooterView {
    
    var delegate: CheckAvailabilityDelegate?
    var section: Int?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    private func setupView(){
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(footerView)
        footerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        addSubview(checkAvailable)
        checkAvailable.snp.makeConstraints { (make) in
            make.top.equalTo(footerView).offset(5)
            make.bottom.equalTo(footerView).inset(5)
            make.right.equalTo(footerView).inset(5)
        }
    }

    let footerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainLight
        return view
    }()
    
    lazy var checkAvailable: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Check Availability", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainLight, for: .normal)
        button.backgroundColor = UIColor.randevoo.mainColor
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 15)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        button.addTarget(self, action: #selector(pushAvailabityController(_:)), for: .touchUpInside)
        return button
    }()
    
    @IBAction func pushAvailabityController(_ sender: Any?){
        delegate!.selectAvailability(index: section!)
    }
    
}
