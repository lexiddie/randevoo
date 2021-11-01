//
//  DetailListHeaderCell.swift
//  randevoo
//
//  Created by Xell on 15/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

protocol DetailListHeaderDelegate {
    func viewStore(index: Int)
}

class DetailListHeaderCell: UITableViewHeaderFooterView {
    
    var delegate: DetailListHeaderDelegate?
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
        addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        headerView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.left.top.lessThanOrEqualTo(headerView).offset(5)
        }
        headerView.addSubview(shopName)
        shopName.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(10)
            make.centerY.equalTo(headerView)
        }
        headerView.addSubview(storeButton)
        storeButton.snp.makeConstraints { (make) in
            make.top.lessThanOrEqualTo(headerView).offset(10)
            make.left.lessThanOrEqualTo(shopName.snp.right).offset(10)
            make.centerY.equalTo(headerView)
            make.width.height.equalTo(20)
        }
    }

    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainLight
        return view
    }()
    
    let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.randevoo.mainWhiteGray.cgColor
        imageView.backgroundColor = UIColor.randevoo.mainWhiteGray
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var shopName: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("N/A", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainBlack, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 16)
        button.addTarget(self, action: #selector(viewStore(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var storeButton: UIButton = {
        let button = UIButton(type: .system)
        let imageView = UIImage.init(named: "ArrowRight")
        button.setImage(imageView, for: .normal)
        button.tintColor = UIColor.randevoo.mainBlack
        button.addTarget(self, action: #selector(viewStore(_:)), for: .touchUpInside)
        return button
    }()
    
    
    @IBAction func viewStore(_ sender: Any) {
        delegate?.viewStore(index: section!)
    }
    


}
