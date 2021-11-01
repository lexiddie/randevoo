//
//  FilterController.swift
//  randevoo
//
//  Created by Xell on 17/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class FilterCategory: Codable {
    var type: String? = ""
    var categories: [String] = []

    
    init(type: String, categories: [String]) {
        self.type = type
        self.categories = categories
    }
}

class FilterController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, InputPriceDelegate {
    
    var mainCollectionView: UICollectionView!
    var filters: [FilterCategory] = [FilterCategory(type: "Sort By", categories: ["Latest", "Earliest"]),FilterCategory(type: "Price", categories: ["Low - High", "High - Low"]),FilterCategory(type: "Minimum Price", categories: ["Nearby"]),FilterCategory(type: "Maximum Price", categories: ["Nearby"])]
    let filterCollectionCell = "filterCollectionCell"
    let inputPriceCell = "inputPriceCell"
    var filterString = ""
    var filterMinPrice = 0
    var filterMaxPrice = 0
    var mainController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.randevoo.mainLight
        initialView()
        setToDefault()
        initialCollectionView()
    }
    
    private func initialView(){
        let view = FilterView(frame: self.view.frame)
        self.mainCollectionView = view.mainCollectionView
        self.view = view
    }
    
    private func initialCollectionView(){
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(FilterCollectionCell.self, forCellWithReuseIdentifier: filterCollectionCell)
        mainCollectionView.register(InputPriceCell.self, forCellWithReuseIdentifier: inputPriceCell)
    }
    
    private func setToDefault() {
        if filterMinPrice != 0 || filterMaxPrice != 0 {
            filterString = ""
        }
    }
    
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: InputPriceCell) {
        if let indexPath = mainCollectionView.indexPath(for: cell), let text = textField.text{
            print("textField text: \(text) from cell: \(indexPath))")
            if indexPath.row  == 2 {
                if text == "" {
                    filterMinPrice = 0
                } else {
                    filterMinPrice = Int(text)!
                }
            } else {
                if text == "" {
                    filterMaxPrice = 0
                } else {
                    filterMaxPrice = Int(text)!
                }
            }
        }
    }
    
    func setMinMaxToDefault() {
        filterMinPrice = 0
        filterMaxPrice = 0
        mainCollectionView.reloadData()
    }
    
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: InputPriceCell) -> Bool {
        print("Validation action in textField from cell: \(String(describing: mainCollectionView.indexPath(for: cell)))")
        return true
    }
    
    @IBAction func applyFilter() {
        if filterMinPrice > filterMaxPrice && filterMaxPrice != 0{
            filterMaxPrice = filterMinPrice + 1000
        }
        let controller = mainController as! HomeController
        controller.filterProduct(filter: filterString, minPrice: filterMinPrice, maxPrice: filterMaxPrice)
        dismiss(animated: true, completion: nil)
    }

}
extension FilterController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let customHeight = CGFloat(filters[indexPath.row].categories.count * 25) + 45
        return CGSize(width: view.frame.width, height: customHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if filters[indexPath.row].type == "Minimum Price" || filters[indexPath.row].type == "Maximum Price" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputPriceCell, for: indexPath) as! InputPriceCell
            if filters[indexPath.row].type == "Minimum Price" {
                cell.price = filterMinPrice
            } else {
                cell.price = filterMaxPrice
            }
            cell.inputTitle.text = filters[indexPath.row].type
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCollectionCell, for: indexPath) as! FilterCollectionCell
            cell.filter = filters[indexPath.row].categories
            cell.currentTitle = filters[indexPath.row].type
            cell.filterFromController = filterString
            cell.previousController = self
            return cell
        }
     
    }
}
