//
//  BizCollectionView.swift
//  randevoo
//
//  Created by Lex on 1/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class BizCollectionView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
    }

}
