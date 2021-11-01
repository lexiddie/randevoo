//
//  BizReservationCell.swift
//  randevoo
//
//  Created by Lex on 28/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class BizReservationCell: UICollectionViewCell {
    
    var reservation: Reservation? {
        didSet {
            guard let reservation = reservation else { return }

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
    }
}
