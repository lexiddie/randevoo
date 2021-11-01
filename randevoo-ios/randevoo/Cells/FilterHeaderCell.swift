//
//  FilterHeaderCell.swift
//  randevoo
//
//  Created by Xell on 17/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

protocol FilterDelegate {
    func selectFilter()
    func selectCategory()
}

class FilterHeaderCell: UICollectionViewCell {
    
    var delegate: FilterDelegate?
    
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
    
    
    private func setupUI(){
        //        addSubview(background)
        //        background.snp.makeConstraints { (make) in
        //            make.top.equalTo(self).offset(5)
        //            make.left.lessThanOrEqualTo(self).offset(10)
        //            make.bottom.equalTo(self).inset(5)
        //        }
        addSubview(filterStackView)
        filterStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        filterStackView.addArrangedSubview(filterButtons)
        filterStackView.addArrangedSubview(categoryButton)
//        addSubview(filterButtons)
//        filterButtons.snp.makeConstraints { (make) in
//            make.top.equalTo(self).offset(5)
//            make.left.lessThanOrEqualTo(self).offset(10)
//            make.bottom.equalTo(self).inset(5)
//            make.width.equalTo(self.frame.width / 2 - 10)
//        }
//        addSubview(categoryButton)
//        categoryButton.snp.makeConstraints { (make) in
//            make.top.equalTo(self).offset(5)
//            make.left.lessThanOrEqualTo(filterButtons.snp.right).offset(10)
//            make.bottom.equalTo(self).inset(5)
//            make.width.equalTo(self.frame.width / 2 - 10)
//        }
    }
    
    let filterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.alignment = UIStackView.Alignment.leading
        stackView.distribution = UIStackView.Distribution.fillEqually
        return stackView
    }()

    lazy var filterButtons: UIButton = {
        let button = UIButton(type: .system)
        let listImg = UIImage(named: "MenuIcon")
        button.setImage(listImg, for: .normal)
        button.backgroundColor = UIColor.white
        button.setTitle("Filter", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainBlack, for: .normal)
        button.tintColor = UIColor.black
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5);
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 18)
        button.contentEdgeInsets = UIEdgeInsets(top:5,left: 15,bottom: 5,right: 15)
        button.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(filterClicked(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        let listImg = UIImage(named: "MenuIcon")
        button.setImage(listImg, for: .normal)
        button.backgroundColor = UIColor.white
        button.setTitle("Category", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainBlack, for: .normal)
        button.tintColor = UIColor.black
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5);
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 18)
        button.contentEdgeInsets = UIEdgeInsets(top:5,left: 15,bottom: 5,right: 15)
        button.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(categoryClicked(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    
    @IBAction func filterClicked(_ sender: Any?){
        delegate?.selectFilter()
    }
    
    @IBAction func categoryClicked(_ sender: Any?){
        delegate?.selectCategory()
    }
    
    
    
}
