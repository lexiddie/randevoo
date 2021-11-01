//
//  BizVariationController.swift
//  randevoo
//
//  Created by Lex on 17/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import ObjectMapper
import SwiftyJSON
import Alamofire
import AlamofireImage
import Cache
import SnapKit
import Hydra
import Presentr

class BizVariationController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BizQuantityCellDelegate {

    var isBizProduct: Bool = false
    var previousController: UIViewController!
    var subcategory: Subcategory!
    
    private let alertHelper = AlertHelper()
    private let bizColorCell = "bizColorCell"
    private let bizSizeCell = "bizSizeCell"
    private let bizQuantityCell = "bizQuantityCell"
    private var variationCollectionView: UICollectionView!
    
    private var size = ""
    private var color = ""
    private var quantity = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        initialCollectionView()
    }
    
    private func initialView() {
        let view = BizVariationView(frame: self.view.frame)
        self.variationCollectionView = view.variationCollectionView
        self.view = view
    }
    
    private func initialCollectionView() {
        variationCollectionView.delegate = self
        variationCollectionView.dataSource = self
        variationCollectionView.register(BizColorCell.self, forCellWithReuseIdentifier: bizColorCell)
        variationCollectionView.register(BizSizeCell.self, forCellWithReuseIdentifier: bizSizeCell)
        variationCollectionView.register(BizQuantityCell.self, forCellWithReuseIdentifier: bizQuantityCell)
        variationCollectionView.keyboardDismissMode = .onDrag
    }
    
    func grabSize(size: String) {
        self.size = size
    }
    
    func grabColor(color: String) {
        self.color = color
    }
    
    @IBAction func handleConfirm(_ sender: Any?) {
        if (color.isEmpty && color == "") || (size.isEmpty && size == "") {
            alertHelper.showAlert(title: "Notice", alert: "Color or Size must not be empty!", controller: self)
        } else {
            let controller = previousController as! BizProductController
            let variant = Variant(color: color, size: size, quantity: quantity, available: quantity)
            controller.appendVariant(variant: variant)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }

}

extension BizVariationController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: 110)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bizColorCell, for: indexPath) as! BizColorCell
            cell.parentController = self
            cell.extractColor(subcategory: subcategory)
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bizSizeCell, for: indexPath) as! BizSizeCell
            cell.parentController = self
            cell.extractSize(subcategory: subcategory)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bizQuantityCell, for: indexPath) as! BizQuantityCell
            cell.delegate = self
            return cell
        }
    }
    
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: BizQuantityCell) {
        let text = String(cell.numberTextField.text!)
        let number = Int(text)
        if number != nil {
            quantity = number!
            print("number!", number!)
        }
    }
    
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: BizQuantityCell) -> Bool {
        return true
    }
    
    func plusAmount() -> Int {
        quantity += 1
        return quantity
    }
    
    func minusAmount() -> Int {
        if quantity <= 1 {
            quantity = 1
        } else {
            quantity -= 1
        }
        return quantity
    }

}
