//
//  AboutSizeCollectionCell.swift
//  randevoo
//
//  Created by Xell on 9/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class AboutSizeCollectionCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    let sizeCell  = "SizeCell"
    var sizeArray: [String] = []
    var selectedSize: String?
    var mainController: UIViewController!
    
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
            make.top.equalTo(self).offset(5)
            make.left.lessThanOrEqualTo(self).offset(10)
        }
        addSubview(sizeCollectionView)
        sizeCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.bottom.equalTo(self).inset(10)
        }
    }
    
    func extractSize(selectedSub: Subcategory){
        if selectedSub != nil {
            let currentSize = selectedSub.variations.filter({$0.name == "size"})
            if currentSize.count != 0 {
                sizeArray = currentSize[0].values
            } else {
                let controller = mainController as! AboutProductViewController
                sizeArray.append("None")
                selectedSize = sizeArray[0]
                controller.grabSize(size: selectedSize!)
            }
        }
        sizeCollectionView.reloadData()
    }
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "None"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
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

extension AboutSizeCollectionCell {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = sizeArray[indexPath.item]
        var width = 0
        if sizeArray[indexPath.item].count < 5 {
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
        return sizeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sizeCell, for: indexPath) as! SizeCell
        if selectedSize == sizeArray[indexPath.row] {
            cell.background.backgroundColor = UIColor.white
            cell.sizeLabel.textColor = UIColor.randevoo.mainColor
            cell.background.layer.borderWidth = 1
            cell.background.layer.borderColor = UIColor.randevoo.mainColor.cgColor
            cell.sizeLabel.text = String(sizeArray[indexPath.row])
        } else {
            cell.background.backgroundColor = UIColor.randevoo.mainLight
            cell.sizeLabel.textColor = UIColor.black
            cell.background.layer.borderWidth = 0
            cell.background.layer.borderColor = UIColor.white.cgColor
            cell.sizeLabel.text = String(sizeArray[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = mainController as! AboutProductViewController
        let cell = collectionView.cellForItem(at: indexPath) as! SizeCell
        cell.background.backgroundColor = UIColor.white
        cell.sizeLabel.textColor = UIColor.randevoo.mainColor
        cell.background.layer.borderWidth = 1
        cell.background.layer.borderColor = UIColor.randevoo.mainColor.cgColor
        selectedSize = sizeArray[indexPath.row]
        controller.grabSize(size: sizeArray[indexPath.row])
        sizeCollectionView.reloadData()
    }
    
}
