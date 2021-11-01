//
//  ListDetailCell.swift
//  randevoo
//
//  Created by Xell on 15/11/2563 BE.
//  Copyright © 2563 Lex. All rights reserved.
//

import UIKit

//protocol SelecSectionDelegate {
//    func addNewImage(footer: )
//}


class ListDetailCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        let height = frame.height / 5
        let width = frame.width / 3
        let textWidth = frame.width - width - 10
        addSubview(productImg)
        productImg.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.bottom.equalTo(self).inset(10)
            make.height.equalTo(height)
            make.width.equalTo(width)
        }
        addSubview(productSize)
        productSize.snp.makeConstraints { (make) in
            make.left.equalTo(productImg.snp.right).offset(40)
            make.centerY.equalTo(productImg)
        }
        addSubview(productPrice)
        productPrice.snp.makeConstraints { (make) in
            make.bottom.equalTo(productSize).inset(25)
            make.left.equalTo(productImg.snp.right).offset(40)
        }
        addSubview(productName)
        productName.snp.makeConstraints { (make) in
            make.bottom.equalTo(productPrice).inset(25)
            make.left.equalTo(productImg.snp.right).offset(40)
            make.right.equalTo(self).inset(10)
            make.width.equalTo(textWidth)
        }
        addSubview(productColor)
        productColor.snp.makeConstraints { (make) in
            make.top.equalTo(productSize.snp.bottom).offset(10)
            make.left.equalTo(productImg.snp.right).offset(40)
        }
        addSubview(productQuantity)
        productQuantity.snp.makeConstraints { (make) in
            make.top.equalTo(productColor.snp.bottom).offset(10)
            make.left.equalTo(productImg.snp.right).offset(40)
        }
        addSubview(unavailableView)
        unavailableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        unavailableView.addSubview(unavailableLabel)
        unavailableLabel.snp.makeConstraints { (make) in
            make.center.equalTo(unavailableView)
        }
    }
    
    let productImg: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let productName: UILabel = {
        let label = PaddingLabel()
        label.text = "4,000 Baht"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Medium", size: 15)
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    let productPrice: UILabel = {
        let label = PaddingLabel()
        label.text = "4,000 Baht"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    let productSize: UILabel = {
        let label = PaddingLabel()
        label.text = "4,000 Baht"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    let productColor: UILabel = {
        let label = PaddingLabel()
        label.text = "4,000 Baht"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    let productQuantity: UILabel = {
        let label = PaddingLabel()
        label.text = "4,000 Baht"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Regular", size: 15)
        label.minimumScaleFactor = 0.5
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    let unavailableView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let unavailableLabel: UILabel = {
        let label = PaddingLabel()
        label.text = ""
        label.textColor = UIColor.randevoo.mainRed.withAlphaComponent(0.8)
        label.font = UIFont(name: "Quicksand-Regular", size: 18)
        label.backgroundColor = UIColor.clear
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.minimumScaleFactor = 0.5
        label.padding(7, 7, 7, 7)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    

}
