//
//  FilterReservationController.swift
//  randevoo
//
//  Created by Xell on 28/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class FilterReservationController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var mainController: UIViewController!
    var mainCollectionView: UICollectionView!
    let filterCollectionCell = "filterCollectionCell"
    let filters = ["Latest", "Earliest", "Completed", "Approved", "Failed", "Pending"]
    var filterString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.randevoo.mainLight
        initialView()
        initialCollectionView()
    }
    
    private func initialView(){
        let view = FilterReservationView(frame: self.view.frame)
        self.mainCollectionView = view.mainCollectionView
        self.view = view
    }
    
    private func initialCollectionView(){
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(FilterReservationCell.self, forCellWithReuseIdentifier: filterCollectionCell)
    }
    
    @IBAction func applyFilter(_ sender: Any) {
        let controller = mainController as! ReservationController
        dismiss(animated: true, completion: {
            controller.applyFilter(filter: self.filterString)
        })
    }
    

}
extension FilterReservationController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 30)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCollectionCell, for: indexPath) as! FilterReservationCell
        cell.title = filters[indexPath.row]
        if filterString == filters[indexPath.row] {
            cell.indicateImageView.image = UIImage(named: "Tick")!.withRenderingMode(.alwaysOriginal)
            cell.titleLabel.textColor = UIColor.randevoo.mainColor
        } else {
            cell.indicateImageView.image = UIImage(named: "")
            cell.titleLabel.textColor = UIColor.randevoo.mainBlack
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterString = filters[indexPath.row]
        mainCollectionView.reloadData()
//        mainCollectionView.reloadData()
    }
    
}

