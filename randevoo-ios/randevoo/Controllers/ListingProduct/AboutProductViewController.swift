//
//  AboutProductViewController.swift
//  randevoo
//
//  Created by Xell on 9/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class AboutProductViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UpdateAmountDelegate {
    
    var mainCollectionView: UICollectionView!
    var aboutSizeCell = "aboutSizeCell"
    var aboutColorCell = "aboutColorCell"
    var aboutProductFooterCell = "aboutProductFooterCell"
    var quantity = 1
    var size = ""
    var color = ""
    var isEditVariant = false
    var indexPath: Int?
    var addButton: UIButton!
    var previousController: UICollectionViewCell!
    var selectedSub: Subcategory!
    let alert = AlertHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.randevoo.mainLight
        initialView()
        initialCollectionView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    private func initialView() {
        let view = AboutProductView(frame: self.view.frame)
        self.mainCollectionView = view.mainCollectionView
        self.addButton = view.addButton
        self.view = view
    }
    
    private func initialCollectionView() {
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(AboutSizeCollectionCell.self, forCellWithReuseIdentifier: aboutSizeCell)
        mainCollectionView.register(AboutColorCollectionCell.self, forCellWithReuseIdentifier: aboutColorCell)
        mainCollectionView.register(AboutProductFooterCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: aboutProductFooterCell)
    }
    
    func grabSize(size: String) {
        self.size = size
    }
    
    func grabColor (color: String) {
        self.color = color
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        let viewController = self.previousController as! SizeColorCollectionCell
        if size != "" && color != "" {
            if isEditVariant {
                let variant = Variant(color: color, size: size, quantity: quantity, available: quantity)
                self.dismiss(animated: true, completion: {
                    var isExist = false
                    for vari in 0...viewController.variants.count - 1 {
                        if viewController.variants[vari].color == variant.color && viewController.variants[vari].size == variant.size {
                            if self.indexPath != nil {
                                if vari == self.indexPath {
                                    viewController.variants[self.indexPath!] = variant
                                    isExist = true
                                    break
                                } else {
                                    print(viewController.variants[vari].quantity)
                                    let newVariant = viewController.variants[vari].quantity + variant.quantity
                                    viewController.variants[vari].quantity = newVariant
                                    viewController.variants.remove(at: self.indexPath!)
                                    isExist = true
                                    break
                                }
                            }
                        }
                    }
                    if !isExist {
                        viewController.variants[self.indexPath!] = variant
                    }
                    viewController.setProductInformation()
                    viewController.sizeColorCollectionView.reloadData()
                })
            } else{
                let variant = Variant(color: color, size: size, quantity: quantity, available: quantity)
                self.dismiss(animated: true, completion: {
                    var isExist = false
                    for vari in viewController.variants {
                        if vari.color == variant.color && vari.size == variant.size {
                            let newVariant = vari.quantity + variant.quantity
                            vari.quantity = newVariant
                            isExist = true
                            break
                        }
                    }
                    if !isExist {
                        viewController.variants.append(variant)
                    }
                    viewController.setProductInformation()
                    viewController.sizeColorCollectionView.reloadData()
                })
            }
        } else {
            if size == "" {
                alert.showAlert(title: "Missing Size", alert: "", controller: self)
            } else if color == "" {
                alert.showAlert(title: "Missing Color", alert: "", controller: self)
            }

        }
    }
    
    func increaseAmount() -> Int {
        quantity += 1
        return quantity
    }
    
    func decreaseAmount() -> Int {
        if quantity <= 1 {
            quantity = 1
        } else {
            quantity -= 1
        }
        return quantity
    }
    
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: AboutProductFooterCell) {
        let text = String(cell.numberTextField.text!)
        let number = Int(text)
        if number != nil {
            quantity = number!
        }
    }
    
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: AboutProductFooterCell) -> Bool {
        return true
    }
    
}

extension AboutProductViewController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: aboutProductFooterCell, for: indexPath) as! AboutProductFooterCell
        footer.delegate = self
        footer.controller = self
        if isEditVariant {
            footer.numberTextField.text = String(quantity)
        }
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 90)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: aboutSizeCell, for: indexPath) as! AboutSizeCollectionCell
            cell.mainController = self
            cell.titleLabel.text = "Size"
            if isEditVariant {
                cell.selectedSize = size
            }
            cell.extractSize(selectedSub: selectedSub)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: aboutColorCell, for: indexPath) as! AboutColorCollectionCell
            cell.mainController = self
            cell.titleLabel.text = "Color"
            cell.extractColor(selectedSub: selectedSub)
            if isEditVariant {
                cell.selectedColor = color
            }
            return cell
        }
    }
    
}
