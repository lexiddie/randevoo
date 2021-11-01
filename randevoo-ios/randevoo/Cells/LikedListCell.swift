//
//  LikedListCell.swift
//  randevoo
//
//  Created by Xell on 15/11/2563 BE.
//  Copyright © 2563 Lex. All rights reserved.
//

import UIKit

class LikedListCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
//        setupNameLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
    }
    
    let productImg: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15
        return imageView
        
    }()
    

    

}
