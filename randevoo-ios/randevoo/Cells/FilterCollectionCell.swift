//
//  FilterCollectionCell.swift
//  randevoo
//
//  Created by Xell on 17/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class FilterCollectionCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let filterTitleCell = "FilterTitleCellID"
    var filterTitleArray: [String] = []
    var filter: [String]? {
        didSet {
            guard let fil = filter else { return }
            filterTitleArray = fil
            mainCollectionView.reloadData()
        }
    }
    var currentTitle: String? {
        didSet {
            guard let title = self.currentTitle  else { return }
            titleLabel.text = title
        }
    }
    var filterString = ""
    var filterFromController: String? {
        didSet {
            guard let filter = self.filterFromController else { return }
            filterString = filter
            mainCollectionView.reloadData()
        }
    }
    var previousController: UIViewController!
    var price = ""
    
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
        addSubview(mainCollectionView)
        mainCollectionView.snp.makeConstraints { (make) in
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
    
    lazy var mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    private func initiateCollectionView() {
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(FilterCollectionTitleCell.self, forCellWithReuseIdentifier: filterTitleCell)
    }
    
}
extension FilterCollectionCell {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        let label = UILabel()
        //        label.text = colorArray[indexPath.item].color
        return CGSize(width: self.frame.width, height: 25)
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
        return filterTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterTitleCell, for: indexPath) as! FilterCollectionTitleCell
        cell.currentTitle = filterTitleArray[indexPath.row]
        if filterTitleArray[indexPath.row] == filterString {
            cell.indicateImageView.image = UIImage(named: "Tick")!.withRenderingMode(.alwaysOriginal)
            cell.titleLabel.textColor = UIColor.randevoo.mainColor
        } else {
            cell.indicateImageView.image = UIImage(named: "")
            cell.titleLabel.textColor = UIColor.randevoo.mainBlack
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = previousController as! FilterController
        filterString = filterTitleArray[indexPath.row]
        controller.filterString = filterString
        controller.setMinMaxToDefault()
        controller.mainCollectionView.reloadData()
//        mainCollectionView.reloadData()
    }
    
}

