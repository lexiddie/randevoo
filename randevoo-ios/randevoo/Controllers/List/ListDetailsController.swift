//
//  ListDetailsController.swift
//  randevoo
//
//  Created by Xell on 15/11/2563 BE.
//  Copyright © 2563 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import ObjectMapper
import SwiftyJSON
import Presentr

class ListDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource, CheckAvailabilityDelegate, DetailListHeaderDelegate {

    let listCell = "listCell"
    let footerCell = "detailListFooterCell"
    let headerCell = "detailListHeaderCell"
    var previousController: UIViewController!
    let db = Firestore.firestore()
    let alertHelper = AlertHelper()
    var seperates: [[DisplayList]] = []
    var storeAccounts: [StoreAccount] = []
    var products: [Product] = []
    var lists: [ListModel] = []
    var seperateInfo: [[ListModel]] = []
    let addToListHelper = AddToListHelper()
    var timeslots: [Timeslot] = []
    var bizPeriod: [BizPeriod] = []
    var userTimeslot: [Timeslot] = []
    var productSizes: [String] = []
    var productColors: [String] = []
    var disableSection: [Int] = []
    var unavailableProduct: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        view.backgroundColor = UIColor.white
        setupTableView()
        checkIfLogin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
    }
    
    let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        table.allowsSelection = true
        table.backgroundColor = UIColor.randevoo.mainLight
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    let friendlyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    
    private func loadFriendlyLabel() {
        if products.count == 0 {
            friendlyLabel.text = "No products in your bag🚀😬"
        } else {
            friendlyLabel.text = nil
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(ListDetailCell.self, forCellReuseIdentifier: listCell)
        tableView.register(DetailListHeaderCell.self, forHeaderFooterViewReuseIdentifier: headerCell)
        tableView.register(DetailListFooterCell.self, forHeaderFooterViewReuseIdentifier: footerCell)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        view.addSubview(friendlyLabel)
        friendlyLabel.snp.makeConstraints { (make) in
            make.left.right.lessThanOrEqualTo(20)
            make.height.equalTo(35)
            make.center.equalTo(tableView)
        }
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Your Bag"
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
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func checkIfLogin() {
        if !isSignIn {
            alertHelper.showAlert(title: "Notice", alert: "Please sign in to continue! 😫", controller: self)
        } else {
            guard let personal = personalAccount else { return }
            retrieveProductFromList(personalId: personal.id)
            retrieveUserTimeslot(accountId: personal.id)
            loadFriendlyLabel()
        }
    }
    
    func retrieveProductFromList(personalId: String){
        let prodListDb = db.collection("bags")
        prodListDb.whereField("userId", isEqualTo: personalId).getDocuments() {(querySnapShot, err) in
            if err != nil {
                print("Fail to Retrieve User Product List")
            } else {
                for document in querySnapShot!.documents {
                    let currentData = Mapper<ListModel>().map(JSONObject: document.data())
                    self.lists.append(currentData!)
                }
                self.retrieveProduct(currentList: self.lists)
            }
        }
        tableView.reloadData()
    }
    
    func separateProducts(products: [Product]) {
        seperates.removeAll()
        disableSection.removeAll()
        var isFound = false
        for list in lists {
            if seperates.count == 0 {
                var currentList: [DisplayList] = []
                let currentProduct = products.filter({$0.id == list.productId})
                if currentProduct.count != 0 {
                    let displayList = DisplayList(product: currentProduct[0], information: list)
                    currentList.append(displayList)
                    seperates.append(currentList)
                }
            } else {
                for i in  0...seperates.count - 1 {
                    let thisProduct = products.filter({$0.id == list.productId})
                    if thisProduct.count != 0 {
                        if seperates[i].contains(where: {$0.product.businessId == thisProduct[0].businessId}) {
                            if !seperates[i].contains(where: {$0.information.id == list.id}) {
                                let displayList = DisplayList(product: thisProduct[0], information: list)
                                seperates[i].append(displayList)
                                isFound = true
                                break
                            }
                        } else {
                            isFound = false
                        }
                    }
                }
                if !isFound {
                    let currentProduct = products.filter({$0.id == list.productId})
                    if currentProduct.count != 0{
                        var currentList: [DisplayList] = []
                            currentList.append(DisplayList(product: currentProduct[0], information: list))
                            seperates.append(currentList)
                    }
                }
            }
            loadFriendlyLabel()
            self.tableView.reloadData()
            for list in seperates {
                if list.count != 0 {
                    self.fetchStore(storeId: list[0].product.businessId)
                }
            }
        }
    }

    func retrieveProduct(currentList: [ListModel]){
        let productCollection = db.collection("products")
        for list in currentList {
            productCollection.whereField("id", isEqualTo: list.productId!).addSnapshotListener() {(querySnapShot, err) in
                if err != nil {
                    print("Fail to Retrieve User Product List")
                } else {
                    for document in querySnapShot!.documents {
                        let currentData = Mapper<Product>().map(JSONObject: document.data())
                        if !self.products.contains(where: {$0.id == currentData?.id}) {
                            self.products.append(currentData!)
                        } else {
                            let currentIndex = self.products.firstIndex(where: {$0.id == currentData?.id})
                            if currentIndex != nil {
                                self.products.remove(at: currentIndex!)
                                print(self.products.count)
                                self.products.append(currentData!)
                            }
                            //                            }
                        }
                        if !self.storeAccounts.contains(where: { $0.id == currentData?.businessId}) {
                            self.fetchStore(storeId: (currentData?.businessId)!)
                            self.retrieveTimeSlot(storeId: (currentData?.businessId)!)
                            self.retrieveStorePeriod(storeId: (currentData?.businessId)!)
                        }
                    }
                    self.separateProducts(products: self.products)
                }
            }
        }
    }
    
    private func fetchStore(storeId: String) {
        let businessRef = self.db.collection("businesses")
        businessRef.document(storeId).getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let result = Mapper<StoreAccount>().map(JSONObject: document.data())!
                if !self.storeAccounts.contains(where: {$0.id == result.id}) {
                    self.storeAccounts.append(result)
                    tableView.reloadData()
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func selectAvailability(index: Int) {
        let availabilityController = AvailabilityController()
        print(index)
        availabilityController.products = seperates[index]
        var currentBiz: StoreAccount!
        var currentTimeSlot: [Timeslot] = []
        var currentBizPeriod: [BizPeriod] = []
        if seperates[index].count != 0 {
            let extractBiz = storeAccounts.filter({$0.id == seperates[index][0].product.businessId})
            if extractBiz.count != 0 {
                currentBiz = extractBiz[0]
                currentTimeSlot = timeslots.filter({$0.businessId == currentBiz.id})
                currentBizPeriod = bizPeriod.filter({$0.businessId == currentBiz.id})
            }
        } else {
            currentBiz = storeAccounts[index]
        }
        print(timeslots.count)
        print(currentTimeSlot.count)
        availabilityController.storeAccount = currentBiz
        if currentBizPeriod.count != 0 {
            availabilityController.storePeriod = currentBizPeriod[0]
        }
        availabilityController.storeTimeslots = currentTimeSlot
        availabilityController.customerTimeslots = userTimeslot
        availabilityController.isFirstLoad = true
        navigationController?.pushViewController(availabilityController, animated: true)
    }
    
    
    func viewStore(index: Int) {
        var storeId = ""
        if storeAccounts.count != 0 {
            let currentBiz = storeAccounts.filter({$0.id == seperates[index][0].product.businessId})
            if currentBiz.count != 0 {
                storeId = currentBiz[0].id
            }
        }
        let controller = StoreController()
        controller.storeId = storeId
        navigationController?.pushViewController(controller, animated: true)
    }
    

    func retrieveTimeSlot(storeId: String) {
        let timeslotRef = db.collection("timeslots")
        timeslotRef.whereField("businessId", isEqualTo: storeId).getDocuments() { [self](querySnapShot, err) in
            if err != nil {
                print("Fail to Retrieve User Product List")
            } else {
                for document in querySnapShot!.documents {
                    let currentData = Mapper<Timeslot>().map(JSONObject: document.data())
                    if !self.timeslots.contains(where: { time in time.id == currentData?.id }) {
                        timeslots.append(currentData!)
                    }
                }
            }
        }
    }
    
    func retrieveUserTimeslot(accountId: String) {
        let timeslotRef = db.collection("timeslots")
        timeslotRef.whereField("userId", isEqualTo: accountId ).getDocuments() { [self](querySnapShot, err) in
            if err != nil {
                print("Fail to Retrieve User Product List")
            } else {
                for document in querySnapShot!.documents {
                    let currentData = Mapper<Timeslot>().map(JSONObject: document.data())
                    if !self.userTimeslot.contains(where: { time in time.id == currentData?.id }) {
                        userTimeslot.append(currentData!)
                    }
                }
            }
        }
    }
    
    func retrieveStorePeriod(storeId: String) {
        let schedule = db.collection("bizPeriods")
        schedule.whereField("businessId", isEqualTo: storeId).getDocuments() { [self](querySnapShot, err) in
            if err != nil {
                print("Fail to Retrieve User Product List")
            } else {
                for document in querySnapShot!.documents {
                    let currentData = Mapper<BizPeriod>().map(JSONObject: document.data())
                    if !bizPeriod.contains(where: {$0.id == currentData?.id}) {
                        bizPeriod.append(currentData!)
                    }
                }
            }
        }
    }
    
    let presenter: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.fluid(percentage: 1)
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
    
    private func setupDisableSection(section: Int) {
        if !disableSection.contains(section) {
            disableSection.append(section)
        }
    }

}

extension ListDetailsController {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nike"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerCell) as! DetailListHeaderCell
        if storeAccounts.count != 0 {
            let currentBiz = storeAccounts.filter({$0.id == seperates[section][0].product.businessId})
            if currentBiz.count != 0 {
                headerView.shopName.setTitle(currentBiz[0].name, for: .normal)
                headerView.imageView.loadCacheImage(urlString: currentBiz[0].profileUrl)
            }
        }
        headerView.delegate = self
        headerView.section = section
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: footerCell) as! DetailListFooterCell
        footerView.delegate = self
        if disableSection.contains(section) {
            footerView.checkAvailable.isEnabled = false
            footerView.checkAvailable.backgroundColor = UIColor.randevoo.mainLightBlue
        } else {
            footerView.checkAvailable.isEnabled = true
            footerView.checkAvailable.backgroundColor = UIColor.randevoo.mainColor
        }
        footerView.section = section
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = view.frame.height / 5 + 20
        return height
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.seperates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seperates[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: listCell, for: indexPath) as! ListDetailCell
        cell.productImg.loadCacheImage(urlString: seperates[indexPath.section][indexPath.row].product.photoUrls[0])
        cell.productName.text = seperates[indexPath.section][indexPath.row].product.name
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let priceFormat = numberFormatter.string(from: NSNumber(value: seperates[indexPath.section][indexPath.row].product.price))
        cell.productPrice.text = "Price: " + priceFormat! + " Baht"
        let filterProduct = products.filter({$0.id == seperates[indexPath.section][indexPath.row].product.id})
        var variants: [Variant] = []
        if filterProduct.count != 0 {
            variants = filterProduct[0].variants.filter({$0.color == seperates[indexPath.section][indexPath.row].information.variant.color && $0.size == seperates[indexPath.section][indexPath.row].information.variant.size })
        }
        if seperates[indexPath.section][indexPath.row].information != nil {
            if filterProduct[0].available <= 0 || filterProduct[0].isBanned || !filterProduct[0].isActive{
                cell.unavailableLabel.isHidden = false
                if !unavailableProduct.contains(where: {$0.id == filterProduct[0].id}) {
                    unavailableProduct.append(filterProduct[0])
                }
                if filterProduct[0].available <= 0 || !filterProduct[0].isAvailable {
                    cell.unavailableLabel.text = "Out Of Stock"
                } else if filterProduct[0].isBanned  {
                    cell.unavailableLabel.text = "Product is currently Banned!"
                } else if !filterProduct[0].isActive {
                    cell.unavailableLabel.text = "Product is currently Removed!"
                }
                setupDisableSection(section: indexPath.section)
                cell.unavailableLabel.backgroundColor = UIColor.white
                cell.unavailableView.backgroundColor = UIColor.randevoo.mainLightGray.withAlphaComponent(0.8)
            }else {
                if variants.contains(where: {$0.color == seperates[indexPath.section][indexPath.row].information.variant.color}) {
                    cell.productColor.textColor = UIColor.black
                    if variants.contains(where: {$0.size == seperates[indexPath.section][indexPath.row].information.variant.size}) {
                        cell.productSize.textColor = UIColor.black
                        if variants[0].available >= seperates[indexPath.section][indexPath.row].information.variant.quantity{
                            cell.productQuantity.textColor = UIColor.black
                        } else {
                            setupDisableSection(section: indexPath.section)
                            cell.productQuantity.textColor = UIColor.red
                        }
                    } else {
                        setupDisableSection(section: indexPath.section)
                        cell.productSize.textColor = UIColor.red
                        cell.productQuantity.textColor = UIColor.red
                    }
                } else {
                    setupDisableSection(section: indexPath.section)
                    cell.productColor.textColor = UIColor.red
                    cell.productSize.textColor = UIColor.red
                    cell.productQuantity.textColor = UIColor.red
                }
                cell.unavailableView.backgroundColor = .clear
                cell.unavailableLabel.isHidden = true
            }
            cell.productSize.text = "Size: " + seperates[indexPath.section][indexPath.row].information.variant.size
            cell.productColor.text = "Color: " + seperates[indexPath.section][indexPath.row].information.variant.color
            cell.productQuantity.text = "Quantity: " + String(seperates[indexPath.section][indexPath.row].information.variant.quantity)
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let alertController = UIAlertController(title: "Delete Product", message: "Are you sure you want to remove this product from list ?", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
                var ids: [String] = []
                for i in self.seperates {
                    for j in i {
                        print("")
                        if j.product.id == self.seperates[indexPath.section][indexPath.row].product.id &&
                            j.information.variant.size == self.seperates[indexPath.section][indexPath.row].information.variant.size && j.information.variant.color == self.seperates[indexPath.section][indexPath.row].information.variant.color  {
                            ids.append(j.information.id)
                            self.addToListHelper.deleteProductFromList(ids: ids)
                        }
                    }
                }
                self.seperates[indexPath.section].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.disableSection.removeAll()
                tableView.reloadData()
                if self.seperates[indexPath.section].count == 0 {
                    self.seperates.remove(at: indexPath.section)
                    tableView.reloadData()
                }
                alertController.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(alertAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        let share = UITableViewRowAction(style: .normal, title: "Edit") { [self] (action, indexPath) in
            //            print(self.seperateList[indexPath.section][indexPath.row].product.name)
            let filterProduct = self.products.filter({$0.id == self.seperates[indexPath.section][indexPath.row].product.id})
            if unavailableProduct.contains(where: {$0.id == filterProduct[0].id}) {
                alertHelper.showAlert(title: "Product is not available to edit!", alert: "", controller: self)
            } else {
                let popupVC = EditListController()
                popupVC.currentProduct = filterProduct[0]
                popupVC.section = indexPath.section
                popupVC.row = indexPath.row
                popupVC.previousController = self
                popupVC.isFirstLoad = true
                popupVC.seperateList = seperates
                let listsFilter = lists.filter({$0.variant.color == self.seperates[indexPath.section][indexPath.row].information.variant.color && $0.variant.size == self.seperates[indexPath.section][indexPath.row].information.variant.size })
                popupVC.list = listsFilter[0]
                var variants: [Variant] = []
                if filterProduct.count != 0 {
                    variants = filterProduct[0].variants.filter({$0.color == self.seperates[indexPath.section][indexPath.row].information.variant.color})
                }
                if self.seperates[indexPath.section][indexPath.row].information != nil {
                    if variants.contains(where: {$0.color == self.seperates[indexPath.section][indexPath.row].information.variant.color}) {
                        popupVC.color = self.seperates[indexPath.section][indexPath.row].information.variant.color
                        popupVC.previousColor = self.seperates[indexPath.section][indexPath.row].information.variant.color
                        if variants.contains(where: {$0.size == seperates[indexPath.section][indexPath.row].information.variant.size}) {
                            popupVC.size = self.seperates[indexPath.section][indexPath.row].information.variant.size
                            popupVC.previousSize = self.seperates[indexPath.section][indexPath.row].information.variant.size
                            if variants[0].quantity >= seperates[indexPath.section][indexPath.row].information.variant.quantity{
                                popupVC.amount =  self.seperates[indexPath.section][indexPath.row].information.variant.quantity
                                popupVC.previousAmount = self.seperates[indexPath.section][indexPath.row].information.variant.quantity
                                popupVC.maxAmount = variants[0].available
                            } else {
                                popupVC.amount = 1
                                popupVC.previousAmount = self.seperates[indexPath.section][indexPath.row].information.variant.quantity
                                popupVC.maxAmount = variants[0].available
                            }
                        } else {
                            popupVC.size = ""
                            popupVC.previousSize = ""
                        }
                    } else {
                        popupVC.color = ""
                        popupVC.previousColor = ""
                        
                    }
                    
                }
                let navController = UINavigationController(rootViewController: popupVC)
                self.customPresentViewController(self.presenter, viewController: navController, animated: true, completion: nil)
            }
        }
        share.backgroundColor = UIColor.gray
        return [delete, share]
    }

}
