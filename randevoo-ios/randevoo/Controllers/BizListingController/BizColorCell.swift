//
//  BizColorCell.swift
//  randevoo
//
//  Created by Lex on 17/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class BizColorCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var parentController: UIViewController!
    let colorCell = "ColorCell"
    var colorList: [String] = []
    var selectedColor: String = ""

    private let colorsProvider = ColorsProvider()
    
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
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(5)
            make.height.equalTo(35)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).offset(10)
        }
        addSubview(colorCollectionView)
        colorCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.bottom.equalTo(self).inset(10)
        }
    }
    
    func extractColor(subcategory: Subcategory){
        let currentColor = subcategory.variations.filter({$0.name == "color"})
        if currentColor.count != 0 {
            colorList = currentColor[0].values
        } else {
            let controller = parentController as! BizVariationController
            colorList.append("None")
            selectedColor = colorList[0]
            controller.grabColor(color: selectedColor)
        }
        colorCollectionView.reloadData()
    }
    
    let nameLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.layer.cornerRadius = 5
        label.text = "Color"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    lazy var colorCollectionView: UICollectionView = {
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
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: colorCell)
    }
    
}

extension BizColorCell {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = colorList[indexPath.row]
        let width = label.intrinsicContentSize.width + 50
        return CGSize(width: width, height: 50)
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
        return colorList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCell, for: indexPath) as! ColorCell
        if selectedColor == colorList[indexPath.row] {
            cell.mainView.layer.borderWidth = 1
            cell.mainView.layer.borderColor = UIColor.randevoo.mainColor.cgColor
            cell.colorLabel.textColor = UIColor.randevoo.mainColor
        } else {
            cell.mainView.layer.borderWidth = 1
            cell.mainView.layer.borderColor = UIColor.randevoo.mainLightGray.cgColor
            cell.colorLabel.textColor = UIColor.black
        }
        cell.mainView.backgroundColor = UIColor.white
        cell.colorIndicator.backgroundColor = UIColor(hex: colorsProvider.getColorCode(name: colorList[indexPath.row]))
        cell.colorLabel.text = colorList[indexPath.row]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = parentController as! BizVariationController
        let cell = collectionView.cellForItem(at: indexPath) as! ColorCell
        cell.mainView.layer.borderWidth = 1
        cell.mainView.layer.borderColor = UIColor.randevoo.mainColor.cgColor
        cell.colorLabel.textColor = UIColor.randevoo.mainColor
        selectedColor = colorList[indexPath.row]
        controller.grabColor(color: colorList[indexPath.row])
        colorCollectionView.reloadData()
    }
    
}
