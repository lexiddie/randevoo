//
//  ConfirmReservationController.swift
//  randevoo
//
//  Created by Xell on 21/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Hydra
import ObjectMapper

class ConfirmReservationController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let confirmProductCell = "ConfirmProductCell"
    var availability : UIViewController!
    var appointmentDate: UILabel!
    var storeName: UILabel!
    var storeLocation: UILabel!
    var totalLabel: UILabel!
    var storeImg: UIImageView!
    var reserveDate = ""
    var reseveTime = ""
    let db = Firestore.firestore()
    var lists: [DisplayList] = []
    var information: [ListModel] = []
    var reservedProducts: [ReservedProduct] = []
    var businessId = ""
    let alertHelper = AlertHelper()
    var personalAccount: PersonalAccount!
    var businessAccount: BusinessAccount!
    var storeAccount: StoreAccount!
    var reservationHelper = ReservationHelper()
    let qrGenerator = QrCodeGenerator()
    let addToListHelper = AddToListHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupView()
        fetchAccounts()
        setupTableView()
        initialInfo()
        generateReservationProduct()
    }
    
    var tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        table.allowsSelection = false
        table.backgroundColor = UIColor.white
        return table
    }()
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConfirmProductCell.self, forCellReuseIdentifier: confirmProductCell)
    }
    
    private func setupView() {
        let view = ConfirmReservationView(frame: self.view.frame)
        tableView = view.tableView
        appointmentDate = view.appointmentDate
        storeName = view.shopName
        storeImg = view.shopImg
        storeLocation = view.shopLocation
        totalLabel = view.totalLabel
        self.view =  view

    }
    
    private func initialInfo() {
        appointmentDate.text = reserveDate + " at: " + reseveTime
        if storeAccount != nil {
            storeName.text = storeAccount.name
            storeImg.loadCacheImage(urlString: storeAccount.profileUrl)
            storeLocation.text = storeAccount.location
        }
        var totalPrice = 0.0
        for list in lists {
            let price = Double(list.product.price) * Double(list.information.variant.quantity)
            totalPrice += price
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let priceFormat = numberFormatter.string(from: NSNumber(value: totalPrice))
        totalLabel.text =  "Total: ฿ \(String(priceFormat!))"
    
    }
    
    @IBAction func cancel(_ sender: Any){
        navigationController?.popViewController(animated: true)
    }
    
    func fetchAccounts() {
        if let personalCache: PersonalAccount = FCache.get("personal"), !FCache.isExpired("personal") {
            self.personalAccount = personalCache
            let personalJson = Mapper().toJSONString(personalCache, prettyPrint: true)!
            print("\nRetrieved Cache Personal at AddToListController: \(personalJson)")
            if let businessCache: BusinessAccount = FCache.get("business"), !FCache.isExpired("business") {
                self.businessAccount = businessCache
                let businessJson = Mapper().toJSONString(businessCache, prettyPrint: true)!
                print("\nRetrieved Cache BizInfo at AddToListController: \(businessJson)")
            }
        }
    }
    
    
    @IBAction func confirm(_ sender: Any) {
        let alertView = alertHelper.displayCreateNewProductAlert(msg: "Book Product ... ", controller: self)
        let timeslotRef = db.collection("timeslots")
        let reserve = db.collection("reservations")
        let timeslotId = timeslotRef.document().documentID
        let reservationId = reserve.document().documentID
        let currentTimeSlot = Timeslot(id: timeslotId, businessId: businessId, userId: personalAccount.id, date: reserveDate, time: reseveTime)
        let qrCode = qrGenerator.qrCode()
        let currentReservation = Reservation(id: reservationId, businessId: storeAccount.id, userId: personalAccount.id, qrCode: qrCode, timeslotId: timeslotId, products: reservedProducts, status: "Pending", createdAt: Date().iso8601withFractionalSeconds)
        var listID: [String] = []
        for list in lists {
            listID.append(list.information.id)
        }
        let _ = async({ _ -> Bool in
            let status = try await(self.reservationHelper.makingReservation(timeSlot: currentTimeSlot, reservation: currentReservation))
            return status
        }).then({ status in
            print(status)
            if status {
                self.addToListHelper.deleteProductFromList(ids: listID)
                alertView.dismiss(animated: true, completion: {
                    self.dismiss(animated: true, completion: { [self] in
                        let summary = ReservationSummaryController()
                        summary.lists = self.lists
                        summary.bookDate = self.reserveDate
                        summary.bookTime = self.reseveTime
                        summary.storeAccount = storeAccount
                        summary.reservationId = qrCode
                        self.availability.navigationController?.pushViewController(summary, animated: true)
                    })
                })
            } else {
                alertView.dismiss(animated: true, completion: {
                    self.alertHelper.showAlertWhenFailToConfirm(title: "Book Product", alert: "Something when wrong, please recheck the products", controller: self)
                })
            }
        })
    }
    
    func dissmissView(){
        dismiss(animated: true, completion: {
            let controller = self.availability as! AvailabilityController
            controller.popNavigation()
        })
    }
    
    private func generateReservationProduct() {
        reservedProducts.removeAll()
        for product in lists {
            let currentBooked = ReservedProduct(productId: product.product.id, variant: Variant(color: product.information.variant.color, size: product.information.variant.size, quantity: product.information.variant.quantity))
            reservedProducts.append(currentBooked)
        }
    }
    
}

extension ConfirmReservationController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let label: UILabel = {
            let label = UILabel()
            label.text = "List: "
            label.textColor = UIColor.randevoo.mainBlack
            label.font = UIFont(name: "Quicksand-Bold", size: 15)
            label.textAlignment = .left
            label.lineBreakMode = NSLineBreakMode.byTruncatingTail
            return label
        }()
        headerView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(headerView)
            make.centerY.equalTo(headerView)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: confirmProductCell , for: indexPath) as! ConfirmProductCell
        cell.noLabel.text = String(indexPath.item + 1) + "."
        cell.productName.text = lists[indexPath.row].product.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}
