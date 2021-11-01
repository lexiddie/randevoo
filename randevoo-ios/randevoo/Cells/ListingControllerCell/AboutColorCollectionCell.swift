//
//  AboutColorCollectionCell.swift
//  randevoo
//
//  Created by Xell on 10/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Hex

class ColorModel: Mappable, Codable {
    
    var name: String! = ""
    var code: String! = ""
  
    
    init(name: String, code: String) {
        self.name = name
        self.code = code
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name <- map["name"]
        code <- map["code"]
    }
    
}

class AboutColorCollectionCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let colorCell  = "ColorCell"
    var colorArray:[String] = []
    var selectedColor = ""
    var color = ""
    var mainController: UIViewController!
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
    
    func extractColor(selectedSub: Subcategory){
        print(selectedSub.label)
        if selectedSub != nil {
            let currentColor = selectedSub.variations.filter({$0.name == "color"})
            if currentColor.count != 0 {
                colorArray = currentColor[0].values
            } else {
                let controller = mainController as! AboutProductViewController
                colorArray.append("None")
                selectedColor = colorArray[0]
                controller.grabColor(color: selectedColor)
            }

        }
        colorCollectionView.reloadData()
    }
    
    private func initiateCollectionView() {
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: colorCell)
    }
 
}

extension AboutColorCollectionCell {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = colorArray[indexPath.row]
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
        if selectedColor == colorArray[indexPath.row] {
            cell.mainView.layer.borderWidth = 1
            cell.mainView.layer.borderColor = UIColor.randevoo.mainColor.cgColor
            cell.colorLabel.textColor = UIColor.randevoo.mainColor
        } else {
            cell.mainView.layer.borderWidth = 1
            cell.mainView.layer.borderColor = UIColor.randevoo.mainLightGray.cgColor
            cell.colorLabel.textColor = UIColor.black
        }
        cell.mainView.backgroundColor = UIColor.white
        cell.colorIndicator.backgroundColor = UIColor(hex: colorsProvider.getColorCode(name: colorArray[indexPath.row]))
        cell.colorLabel.text = colorArray[indexPath.row]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = mainController as! AboutProductViewController
        let cell = collectionView.cellForItem(at: indexPath) as! ColorCell
        cell.mainView.layer.borderWidth = 1
        cell.mainView.layer.borderColor = UIColor.randevoo.mainColor.cgColor
        cell.colorLabel.textColor = UIColor.randevoo.mainColor
        selectedColor = colorArray[indexPath.row]
        controller.grabColor(color: colorArray[indexPath.row])
        colorCollectionView.reloadData()
    }
    
}
