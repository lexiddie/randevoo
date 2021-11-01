//
//  SizeColorCollectionView.swift
//  randevoo
//
//  Created by Xell on 5/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit
import Presentr

class SizeColorCollectionCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SizeColorCollectionCellDelegate, RemoveSizeColorDelegate{

    let sizeColorCell = "SizeColorCell"
    let addNewColorSizeCell = "addNewColorSizeCell"
    var rootViewController: UIViewController!
    var variants: [Variant] = []
    var selectedSub: Subcategory?
    var isSelectCategory = false
    private let colorsProvider = ColorsProvider()

        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        initiateCollectionView()
        reloadCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadCollectionView() {
        print(variants.count)
        if variants.count != 0 {
            sizeColorCollectionView.reloadData()
        }
    }
    
    private func setupUI(){
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(title)
        title.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.left.equalTo(self).offset(10)
            make.height.equalTo(18)
        }
        addSubview(sizeColorCollectionView)
        sizeColorCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(title.snp.bottom).offset(3)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.bottom.equalTo(self).inset(3)
        }
    }
    
    func setProductInformation(){
        let controller = rootViewController as! ListingController
        controller.variants = variants
    }
    
    func removeCell(sizeColorCell: SizeColorCell) {
        let indexPath = sizeColorCollectionView.indexPath(for: sizeColorCell)
        variants.remove(at: indexPath!.row)
        setProductInformation()
        sizeColorCollectionView.reloadData()
    }
    
    func setFooterButton(isSelectSubCat: Bool) {
        isSelectCategory = isSelectSubCat
        sizeColorCollectionView.reloadData()
    }
    
    let presenter: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.fluid(percentage: 0.6)
        let center = ModalCenterPosition.bottomCenter
        let presentr = Presentr(presentationType: .custom(width: width, height: height, center: center))
        presentr.roundCorners = true
        presentr.cornerRadius = 15
        presentr.backgroundColor = UIColor.black
        presentr.backgroundOpacity = 0.7
        presentr.transitionType = .coverVertical
        presentr.dismissTransitionType = .coverVertical
        presentr.dismissOnSwipe = true
        presentr.dismissAnimated = true
        presentr.dismissOnSwipeDirection = .default
        return presentr
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.text = "About Item"
        label.textAlignment = .left
        return label
    }()
    
    lazy var sizeColorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    private func initiateCollectionView() {
        sizeColorCollectionView.delegate = self
        sizeColorCollectionView.dataSource = self
        sizeColorCollectionView.register(AddColorSizeFooterCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: addNewColorSizeCell)
        sizeColorCollectionView.register(SizeColorCell.self, forCellWithReuseIdentifier: sizeColorCell)
    }
    
    func addNewItemDescription() {
        let aboutProductController = AboutProductViewController()
        aboutProductController.previousController = self
        aboutProductController.selectedSub = selectedSub
        let navController = UINavigationController(rootViewController: aboutProductController)
        rootViewController.customPresentViewController(presenter, viewController: navController, animated: true, completion: nil)
//        rootViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func textWidth(text: String, font: UIFont?) -> CGFloat {
        let attributes = font != nil ? [NSAttributedString.Key.font: font] : [:]
        return text.size(withAttributes: attributes as [NSAttributedString.Key : Any]).width
    }

}

extension SizeColorCollectionCell {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font = UIFont(name: "Quicksand-Bold", size: 17)!
        let width = textWidth(text: variants[indexPath.row].color, font: font)
        if width > 50 {
            return CGSize(width: width + 80, height: 110)
        } else {
            return CGSize(width: 130, height: 110)
        }


    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: addNewColorSizeCell, for: indexPath) as! AddColorSizeFooterCell
        footer.delegate = self
        if isSelectCategory {
            footer.addButton.isEnabled = true
            footer.addButton.backgroundColor = UIColor.randevoo.mainColor
        } else {
            footer.addButton.isEnabled = false
            footer.addButton.backgroundColor  = UIColor.randevoo.mainLightBlue
        }
        return footer
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 60, height: 60)
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
        return variants.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sizeColorCell, for: indexPath) as! SizeColorCell
        cell.sizeLabel.text = "Size:  " + variants[indexPath.row].size
        print(variants[indexPath.row].color == "None")
        if variants[indexPath.row].color == "None" {
            cell.colorLabel.text = variants[indexPath.row].color
            cell.colorText.text = "Color: "
            cell.colorText.backgroundColor = UIColor.randevoo.mainLight
        } else {
            cell.colorLabel.text = variants[indexPath.row].color
            cell.colorText.text = ""
            cell.colorText.backgroundColor = UIColor(hex: colorsProvider.getColorCode(name: variants[indexPath.row].color))
        }
        cell.amountLabel.text = "x " + String(variants[indexPath.row].quantity)
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let aboutProductController = AboutProductViewController()
        aboutProductController.previousController = self
        aboutProductController.selectedSub = selectedSub
        aboutProductController.size = variants[indexPath.row].size
        aboutProductController.color = variants[indexPath.row].color
        aboutProductController.quantity = variants[indexPath.row].quantity
        aboutProductController.isEditVariant = true
        aboutProductController.indexPath = indexPath.row
        let navController = UINavigationController(rootViewController: aboutProductController)
        rootViewController.customPresentViewController(presenter, viewController: navController, animated: true, completion: nil)
    }

}
