//
//  BizIndividualDateController.swift
//  randevoo
//
//  Created by Xell on 28/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
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

class BizIndividualDateController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var bizReservationCollectionView: UICollectionView!
    private var friendlyLabel: UILabel!
    private let reservedCustomerCell = "reservedCustomerCell"
    var date = ""
    var bizReservations: [BizReservation] = []
    private let db = Firestore.firestore()
    private var userRef: CollectionReference!
    private var reservationRef: CollectionReference!
    private var timeslotRef: CollectionReference!
    private var bizPeriodRef: CollectionReference!
    var dateTime = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initialCollectionView()
        loadFriendlyLabel()
    }
    
    private func initialView() {
        let view = BizIndividualVIew(frame: self.view.frame)
        self.bizReservationCollectionView = view.bizReservationCollectionView
        self.friendlyLabel = view.friendlyLabel
        self.view = view
    }
    
    private func initialCollectionView() {
        bizReservationCollectionView.delegate = self
        bizReservationCollectionView.dataSource = self
        bizReservationCollectionView.register(ReservedCustomerCell.self, forCellWithReuseIdentifier: reservedCustomerCell)
        bizReservationCollectionView.isScrollEnabled = true
        bizReservationCollectionView.keyboardDismissMode = .onDrag
    }
    
    private func loadFriendlyLabel() {
        if bizReservations.count == 0 {
            friendlyLabel.isHidden = false
        } else {
            friendlyLabel.isHidden = true
        }
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "\(dateTime)"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "ArrowLeft")!.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentHorizontalAlignment = .center
        backButton.contentVerticalAlignment = .center
        backButton.contentMode = .scaleAspectFit
        backButton.backgroundColor = UIColor.white
        backButton.layer.cornerRadius = 8
        backButton.addTarget(self, action: #selector(handleBack(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.snp.makeConstraints{ (make) in
           make.height.width.equalTo(40)
        }
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }


}
extension BizIndividualDateController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: 175)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bizReservations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reservedCustomerCell, for: indexPath) as! ReservedCustomerCell
        cell.reservation = bizReservations[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = ReservedProductController()
        controller.isFromBizReservation = true
        controller.bizReservation = bizReservations[indexPath.item]
        navigationController?.pushViewController(controller, animated: true)
    }
}
