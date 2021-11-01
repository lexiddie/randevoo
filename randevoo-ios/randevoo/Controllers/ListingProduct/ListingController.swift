//
//  ListingController.swift
//  randevoo
//
//  Created by Lex on 18/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import ObjectMapper
import Alamofire
import AlamofireImage
import Cache
import SnapKit
import Hydra

class InputType: Mappable, Codable {
    
    var type: String! = ""
    var content: String! = ""
    
    
    init(type: String, content: String) {
        self.type = type
        self.content = content
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        type <- map["type"]
        content <- map["content"]
    }
    
}

class DemoCategory: Mappable, Codable {
    
    var type: String!
    var category: [String]!
    
    
    init(type: String, category: [String]) {
        self.type = type
        self.category = category
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        type <- map["type"]
        category <- map["category"]
    }
    
}


class ListingController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AddProductDelegate, CollectionTextFieldDelegate, GetTextViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
      
    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()
     
    var listProducts: [ListProduct] = []
    var refreshControl = UIRefreshControl()
    let imageCollectionCell = "ImageCollectionCell"
    var conditionCollectionCell = "ConditionCell"
    let imageCollectionHeaderID = "imageCollectionCell"
    let inputCell = "inputCell"
    let inputCategoryCell = "inputCategoryCell"
    let inputDescriptionCell = "inputDescriptionID"
    let sizeColorCell = "sizeColorCell"
    let footerButtonCell = "footerButtonCell"
    var listingCollectionView: UICollectionView!
    let demoInput:[InputType] = [InputType(type: "Category", content: "Select product category"), InputType(type: "Product Name", content: "Enter product name"),InputType(type: "Price", content: "Enter product price"), InputType(type: "SizeColor", content: "Enter your price"),InputType(type: "Description", content: "Enter your Description")]
    var imagePicker = UIImagePickerController()
    let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
    var productImage: [UIImage] = []
    var variants: [Variant] = []
    var productCategory: DemoCategory!
    var productName: String!
    var productPrice: Double!
    var productDescription = ""
    let addProductHelper = AddProductHelper()
    
    var selectedSubcategory: Subcategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        setupAlertController()
        initialCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        listingCollectionView.reloadData()
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func initialView() {
        let view = ListingView(frame: self.view.frame)
        self.listingCollectionView = view.listingCollectionView
        self.view = view
        self.view.backgroundColor = UIColor.randevoo.mainLight
    }
    
    private func initialCollectionView(){
        listingCollectionView.delegate = self
        listingCollectionView.dataSource = self
        listingCollectionView.register(AddImageCollectionCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: imageCollectionHeaderID)
        listingCollectionView.register(InputTextCell.self, forCellWithReuseIdentifier: inputCell)
        listingCollectionView.register(InputCategoryCell.self, forCellWithReuseIdentifier: inputCategoryCell)
        listingCollectionView.register(InputDescriptionCell.self, forCellWithReuseIdentifier: inputDescriptionCell)
        listingCollectionView.register(SizeColorCollectionCell.self, forCellWithReuseIdentifier: sizeColorCell)
        listingCollectionView.register(FooterButtonCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerButtonCell)
    }
    
    @IBAction func refreshList(_ sender: Any?) {

    }
    
    func setVariants(variants: [Variant]){
        self.variants = variants
    }
    
    func setupProductCategory(category: DemoCategory) {
        self.productCategory = category
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Listing"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(named: "DismissIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        dismissButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentHorizontalAlignment = .center
        dismissButton.contentVerticalAlignment = .center
        dismissButton.contentMode = .scaleAspectFit
        dismissButton.backgroundColor = UIColor.clear
        dismissButton.layer.cornerRadius = 8
        dismissButton.addTarget(self, action: #selector(handleDismiss(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        dismissButton.snp.makeConstraints{ (make) in
            make.height.width.equalTo(40)
        }
    }
    
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: InputTextCell) {
        if let indexPath = listingCollectionView.indexPath(for: cell), let text = textField.text{
            print("textField text: \(text) from cell: \(indexPath))")
            if indexPath.row  == 1 {
                productName = text
            } else {
                let price = Double(text)
                if price == nil {
                    productPrice = 1
                } else {
                    productPrice = price
                }
            }
        }
    }
    
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: InputTextCell) -> Bool {
        print("Validation action in textField from cell: \(String(describing: listingCollectionView.indexPath(for: cell)))")
        return true
    }
    
    func getTextView(text: String) {
        productDescription = text
    }
    
    func getProductImg(imageView: [UIImage]) {
        productImage = imageView
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addProduct() {
        guard let business = businessAccount else { return }
        if productImage.count == 0 {
            self.displayAlertviewWhenFail(title: "Product Image", msg: "Please add some images")
        } else if selectedSubcategory == nil {
            self.displayAlertviewWhenFail(title: "Product Category", msg: "Please select any categories")
        } else if  productName == nil {
            self.displayAlertviewWhenFail(title: "Product Name", msg: "Please fill in product name")
        } else if productPrice == nil {
            self.displayAlertviewWhenFail(title: "Product Price", msg: "Please fill in product price")
        } else if variants.count == 0 {
            self.displayAlertviewWhenFail(title: "Product Information", msg: "Please add product informations")
        } else if productDescription == "" {
            self.displayAlertviewWhenFail(title: "Product Description", msg: "Please fill in product description")
        } else {
            print("run this")
            let currentAlert = displayCreateNewProductAlert()
            let _ = async({ _ -> [String] in
                let imgUrls = try await(self.addProductHelper.uploadPhotos(photos: self.productImage))
                return imgUrls
            }).then({ imgUrl in
                print(imgUrl.count)
                if self.productImage.count == imgUrl.count {
                    print("run thro listing product")
                    let total = self.variants.map({ $0.quantity }).reduce(0,+)
                    var subcategory: [String] = []
                    subcategory.append(self.selectedSubcategory!.name)
                    let product = Product(id: "", businessId: business.id, name: self.productName, price: self.productPrice, subcategoryId: (self.selectedSubcategory?.id)!, variants: self.variants, available: total, description: self.productDescription, photoUrls: imgUrl, createdAt: Date().iso8601withFractionalSeconds)
                    let _ = async({_ -> Bool in
                        let addProductStatus = try await(self.addProductHelper.saveProductToDb(products: product))
                        return addProductStatus
                    }).then({ addProductStatus in
                        print(addProductStatus)
                        if addProductStatus {
                            currentAlert.dismiss(animated: true, completion: {
                                self.displayAlertviewWhenFail(title: "Add Product", msg: "Product Successfully Added")
                            })
                            self.resetView()
                            
                        } else {
                            currentAlert.dismiss(animated: true, completion: {
                                self.displayAlertviewWhenFail(title: "Add Product", msg: "Product Fail to Added")
                            })
                        }
                    })
                }
            })
        }
    }
    
    func resetView() {
        productName = nil
        productImage = []
        productCategory = nil
        productPrice = nil
        productDescription = ""
        variants = []
        listingCollectionView.reloadData()
    }
    
    func displayAlertviewWhenFail(title: String, msg: String) {
        alertController.title = title
        alertController.message = msg
        self.present(alertController, animated: true)
    }
    
    func displayCreateNewProductAlert() -> UIAlertController {
        let pending = UIAlertController(title: "Creating New Product", message: nil, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        pending.view.addSubview(loadingIndicator)
        self.present(pending, animated: true)
        return pending
    }
    
    func stopLoader(loader : UIAlertController) {
        DispatchQueue.main.async {
            loader.dismiss(animated: true, completion: nil)
        }
    }
    
    func setupAlertController(){
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    }

}
extension ListingController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if demoInput[indexPath.row].type == "SizeColor" {
            return CGSize(width: view.frame.width, height: 140)
        } else if demoInput[indexPath.row].type == "Description" {
            return CGSize(width: view.frame.width, height: 200)
        }  else {
            return CGSize(width: view.frame.width, height: 70)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: imageCollectionHeaderID, for: indexPath) as! AddImageCollectionCell
            if productImage.count == 0 {
                header.productPhotos = []
                header.imageCollectionView.reloadData()
            }
            header.viewController = self
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerButtonCell, for: indexPath) as! FooterButtonCell
            footer.delegate = self
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  demoInput.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if  demoInput[indexPath.row].type == "Product Name"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCell, for: indexPath) as! InputTextCell
            cell.inputTitle.text = demoInput[indexPath.row].type
            cell.inputItem.placeholder = demoInput[indexPath.row].content
            cell.inputItem.keyboardType = .alphabet
            if productName != nil {
                cell.inputItem.text = productName
            } else {
                cell.inputItem.text?.removeAll()
            }
            cell.delegate = self
            return cell
        } else if demoInput[indexPath.row].type == "Price" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCell, for: indexPath) as! InputTextCell
            cell.inputTitle.text = demoInput[indexPath.row].type + " (in Baht)"
            cell.inputItem.placeholder = demoInput[indexPath.row].content
            cell.inputItem.keyboardType = .decimalPad
            if productPrice != nil {
                cell.inputItem.text = String(productPrice)
            } else {
                cell.inputItem.text?.removeAll()
            }
            cell.delegate = self
            return cell
        } else if demoInput[indexPath.row].type == "Category" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputCategoryCell, for: indexPath) as! InputCategoryCell
            //            cell.inputItem.isEditable = false
            //            cell.inputItem.isSelectable = false
            cell.inputItem.isUserInteractionEnabled = false
            cell.inputTitle.text = demoInput[indexPath.row].type
            if selectedSubcategory != nil {
                cell.inputItem.attributedPlaceholder = NSAttributedString(string: (selectedSubcategory?.label)!,
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            }
            return cell
        } else if demoInput[indexPath.row].type == "Description" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inputDescriptionCell, for: indexPath) as! InputDescriptionCell
            cell.inputTitle.text = demoInput[indexPath.row].type
            if productDescription == "" {
                cell.inputItem.text.removeAll()
            }
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sizeColorCell, for: indexPath) as! SizeColorCollectionCell
            if variants.count == 0 {
                cell.variants.removeAll()
                cell.sizeColorCollectionView.reloadData()
            }
            if selectedSubcategory == nil {
                cell.setFooterButton(isSelectSubCat: false)
            } else {
                cell.setFooterButton(isSelectSubCat: true)
                cell.selectedSub = selectedSubcategory
            }
            cell.rootViewController = self
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            presentCategory()
        }
    }
    
    private func presentCategory() {
        let controller = CategoryController()
        controller.previousController = self
        controller.isListing = true
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.barTintColor = UIColor.clear
        self.present(navController, animated: true, completion: nil)
    }
    
    func checkingResult() {
        guard let subcategory = selectedSubcategory else { return }
        let json = Mapper().toJSONString(subcategory, prettyPrint: true)!
        print("Subcategory: \(json)")
    }

}

extension UIAlertController {
    
    //Set background color of UIAlertController
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    
    //Set title font and title color
    func setTitle(font: UIFont?, color: UIColor?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)//1
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : titleFont],//2
                                          range: NSMakeRange(0, title.utf8.count))
        }
        
        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor],//3
                                          range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle")//4
    }
    
    //Set message font and message color
    func setMessage(font: UIFont?, color: UIColor?) {
        guard let title = self.message else {
          return
        }
        let attributedString = NSMutableAttributedString(string: title)
        if let titleFont = font {
          attributedString.addAttributes([NSAttributedString.Key.font : titleFont], range: NSMakeRange(0, title.utf8.count))
        }
        if let titleColor = color {
          attributedString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor], range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributedString, forKey: "attributedMessage")//4
      }
    
    //Set tint color of UIAlertController
    func setTint(color: UIColor) {
        self.view.tintColor = color
    }
}

