//
//  HomeCategoryView.swift
//  randevoo
//
//  Created by Lex on 28/8/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class HomeCategoryView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var homeController: HomeController?
    var categories = [Category]()
    let categoryGridCell = "categoryGridCell"
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(categoryCollectionView)
        categoryCollectionView.snp.makeConstraints { (make) in
            make.top.bottom.centerX.centerY.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
        }
        categoryCollectionView.addSubview(selectCategoryButton)
        selectCategoryButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(categoryCollectionView)
            make.height.equalTo(40)
            make.width.equalTo(130)
            make.left.lessThanOrEqualTo(categoryCollectionView).inset(5)
        }
        selectCategoryButton.addSubview(categoryImageView)
        categoryImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(selectCategoryButton)
            make.height.width.equalTo(20)
            make.left.lessThanOrEqualTo(selectCategoryButton).inset(10)
        }
    }

    lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false;
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryGridCell.self, forCellWithReuseIdentifier: categoryGridCell)
        return collectionView
    }()
    
    let selectCategoryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.randevoo.mainLight
        button.contentHorizontalAlignment = .left
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 40, bottom: 0, right: 10)
        button.setTitle("Category", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainBlack, for: .normal)
        button.layer.backgroundColor = UIColor.white.cgColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 17)
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.addTarget(self, action: #selector(HomeController.handleSelectCategory(_:)), for: .touchUpInside)
        return button
    }()
    
    let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "CategoryIcon")!.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 140, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = categories[indexPath.item].name
        return CGSize(width: label.intrinsicContentSize.width + 35, height: 40.0)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryGridCell, for: indexPath) as! CategoryGridCell
        cell.nameLabel.text = categories[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Click in category collection")
    }
}
