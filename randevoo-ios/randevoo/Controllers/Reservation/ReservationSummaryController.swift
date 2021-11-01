//
//  AppointmentSummaryController.swift
//  randevoo
//
//  Created by Xell on 22/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class ReservationSummaryController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ReservationDetailDelegate {

    
    
    var mainCollectionView: UICollectionView!
    let reservatioDetailCell = "ReservationDetailTitleCell"
    let reservationProductCell = "ReservationProductCell"
    var lists: [DisplayList] = []
    var bookDate = ""
    var bookTime = ""
    var reservationId = ""
    var storeAccount: StoreAccount!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavItems()
        initialCollectView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
    }
    
    private func setupView(){
        let view = ReservationSummaryView(frame: self.view.frame)
        mainCollectionView = view.mainCollectionView
        self.view = view
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Reservation"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 20)
        navigationItem.titleView = titleLabel
        self.navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationItem.hidesBackButton = true
  
    }
    
    private func initialCollectView(){
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(ReservationDetailTitleCell.self, forCellWithReuseIdentifier: reservatioDetailCell)
        mainCollectionView.register(ReservationDetailProductCell.self, forCellWithReuseIdentifier: reservationProductCell)
    }
    
    @IBAction func done() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func viewStore() {
        let controller = StoreController()
        controller.storeId = storeAccount.id
        navigationController?.pushViewController(controller, animated: true)
    }

}
extension ReservationSummaryController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            let height = view.frame.width / 2 + 40
            return CGSize(width: view.frame.width, height: height)
        } else {
            let height = view.frame.width / 3
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  lists.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reservatioDetailCell, for: indexPath) as! ReservationDetailTitleCell
            cell.statusView.backgroundColor = UIColor.randevoo.mainDarkYellow.withAlphaComponent(0.2)
            cell.reservationStatus.text = "Pending"
            cell.reservationStatus.textColor = UIColor.randevoo.mainDarkYellow
            cell.scheduleDate.text = bookDate
            cell.scheduleTime.text = bookTime
            cell.shopName.setTitle(storeAccount.name, for: .normal)
            cell.shopImg.loadCacheImage(urlString: storeAccount.profileUrl)
            cell.delegate = self
            cell.id.text = reservationId
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reservationProductCell, for: indexPath) as! ReservationDetailProductCell
            cell.productImg.loadCacheImage(urlString: lists[indexPath.item - 1].product.photoUrls[0])
            cell.productName.text = lists[indexPath.item - 1].product.name
            cell.productSize.text = lists[indexPath.item - 1].information.variant.size
            cell.productColor.text = lists[indexPath.item - 1].information.variant.color
            let totalPrice = Double(lists[indexPath.item - 1].information.variant.quantity) * lists[indexPath.item - 1].product.price
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let priceFormat = numberFormatter.string(from: NSNumber(value: totalPrice))
            cell.productPrice.text =  "฿\(String(priceFormat!))"
            cell.productQuantity.text = "x \(String(lists[indexPath.item - 1].information.variant.quantity))"
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
   
    }
}






