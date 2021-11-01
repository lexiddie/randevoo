//
//  BizSizeCell.swift
//  randevoo
//
//  Created by Lex on 17/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class BizSizeCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var parentController: UIViewController!
    let sizeCell  = "SizeCell"
    var sizeList: [String] = []
    var selectedSize: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        initiateCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(5)
            make.height.equalTo(35)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).offset(10)
        }
        addSubview(sizeCollectionView)
        sizeCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.bottom.equalTo(self).inset(10)
        }
    }
    
    func extractSize(subcategory: Subcategory) {
        let currentSize = subcategory.variations.filter({$0.name == "size"})
        if currentSize.count != 0 {
            sizeList = currentSize[0].values
        } else {
            let controller = parentController as! BizVariationController
            sizeList.append("None")
            selectedSize = sizeList[0]
            controller.grabSize(size: selectedSize)
        }
        sizeCollectionView.reloadData()
    }
    
    let nameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "Size"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    lazy var sizeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.randevoo.mainLight
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

extension BizSizeCell {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = sizeList[indexPath.item]
        var width = 0
        if sizeList[indexPath.item].count < 5 {
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
        return sizeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sizeCell, for: indexPath) as! SizeCell
        if selectedSize == sizeList[indexPath.row] {
            cell.background.backgroundColor = UIColor.white
            cell.sizeLabel.textColor = UIColor.randevoo.mainColor
            cell.background.layer.borderWidth = 1
            cell.background.layer.borderColor = UIColor.randevoo.mainColor.cgColor
            cell.sizeLabel.text = String(sizeList[indexPath.row])
        } else {
            cell.background.backgroundColor = UIColor.randevoo.mainLight
            cell.sizeLabel.textColor = UIColor.black
            cell.background.layer.borderWidth = 0
            cell.background.layer.borderColor = UIColor.white.cgColor
            cell.sizeLabel.text = String(sizeList[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = parentController as! BizVariationController
        let cell = collectionView.cellForItem(at: indexPath) as! SizeCell
        cell.background.backgroundColor = UIColor.white
        cell.sizeLabel.textColor = UIColor.randevoo.mainColor
        cell.background.layer.borderWidth = 1
        cell.background.layer.borderColor = UIColor.randevoo.mainColor.cgColor
        selectedSize = sizeList[indexPath.row]
        controller.grabSize(size: sizeList[indexPath.row])
        sizeCollectionView.reloadData()
    }
    
}
