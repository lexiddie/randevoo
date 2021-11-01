//
//  ProductSizeCell.swift
//  randevoo
//
//  Created by Xell on 8/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class ProductSizeCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let sizeCell  = "sizeCell"
    var sizes: [String] = []
    
    var sizeList: [String]? {
        didSet {
            guard let sizeList = sizeList else { return }
            sizes = sizeList
            
            sizeCollectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.randevoo.mainLight
        setupUI()
        initiateCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.centerX.equalTo(self)
        }
        addSubview(sizeCollectionView)
        sizeCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.bottom.centerX.equalTo(self)
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Size"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    lazy var sizeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private func initiateCollectionView() {
        sizeCollectionView.delegate = self
        sizeCollectionView.dataSource = self
        sizeCollectionView.register(SizeCell.self, forCellWithReuseIdentifier: sizeCell)
    }
}

extension ProductSizeCell {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = sizes[indexPath.item]
        var width = 0
        if sizes[indexPath.item].count < 5 {
            width = Int(label.intrinsicContentSize.width + 40)
        } else {
            width = Int(label.intrinsicContentSize.width + 10)
        }
        return CGSize(width: width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sizes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sizeCell, for: indexPath) as! SizeCell
        cell.sizeLabel.text = sizes[indexPath.row]
        return cell
    }
}
