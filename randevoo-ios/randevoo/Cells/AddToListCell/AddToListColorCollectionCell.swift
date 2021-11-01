//
//  AddTolikeColorCollectionCell.swift
//  randevoo
//
//  Created by Xell on 7/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class AddToListColorCollectionCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let colorCell  = "SizeCell"
    var colorArray: [ColorDisplayModel] = []
    var selectedColor = ""
    var mainController: UIViewController!
    var variants: [Variant] = []
    private let colorProvider = ColorsProvider()
    var currentProduct: Product? {
        didSet {
            guard let product = currentProduct else { return }
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
            make.top.equalTo(self).offset(5)
            make.left.lessThanOrEqualTo(self).offset(10)
        }
        addSubview(colorCollectionView)
        colorCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.bottom.equalTo(self).inset(10)
        }
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
    
    func checkIfArrayEmpty() {
        print(colorArray.count)
        if colorArray.count == 1 {
            let controller = mainController as! AddToListController
            selectedColor = colorArray[0].color
            controller.color  = colorArray[0].color
            controller.grabColor(color: selectedColor)
            controller.setupMaxAmount()
            colorCollectionView.reloadData()
        }
    }
    
    func grabSize(size: String) {
        variants = currentProduct!.variants.filter({ $0.size == size })
        for info in variants {
            print(info.color)
        }
    }
    
}

extension AddToListColorCollectionCell {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = colorArray[indexPath.item].color
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
        return colorArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorCell, for: indexPath) as! ColorCell
        if selectedColor == colorArray[indexPath.row].color {
            cell.mainView.layer.borderWidth = 1
            cell.mainView.layer.borderColor = UIColor.randevoo.mainColor.cgColor
            cell.colorLabel.textColor = UIColor.randevoo.mainColor
        } else {
            cell.mainView.layer.borderWidth = 1
            cell.mainView.layer.borderColor = UIColor.randevoo.mainLightGray.cgColor
            cell.colorLabel.textColor = UIColor.black
        }
        if !colorArray[indexPath.row].isAvailable {
            cell.disableView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        } else {
            cell.disableView.backgroundColor = UIColor.clear
        }
        cell.mainView.backgroundColor = UIColor.white
        cell.colorIndicator.backgroundColor = UIColor.init(hex: colorProvider.getColorCode(name: colorArray[indexPath.row].color))
        cell.colorLabel.text = colorArray[indexPath.row].color
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if colorArray[indexPath.row].isAvailable {
            let controller = mainController as! AddToListController
            let cell = collectionView.cellForItem(at: indexPath) as! ColorCell
            cell.mainView.layer.borderWidth = 1
            cell.mainView.layer.borderColor = UIColor.randevoo.mainColor.cgColor
            cell.colorLabel.textColor = UIColor.randevoo.mainColor
            selectedColor = colorArray[indexPath.row].color
            controller.color  = colorArray[indexPath.row].color
            controller.grabColor(color: selectedColor)
            controller.setupMaxAmount()
            colorCollectionView.reloadData()
        }
    }
    
}
