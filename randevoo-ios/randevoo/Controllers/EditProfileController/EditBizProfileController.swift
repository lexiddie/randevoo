//
//  EditBizProfileController.swift
//  randevoo
//
//  Created by Lex on 28/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import Alamofire
import AlamofireImage
import Hydra
import ObjectMapper
import SwiftyJSON

class EditBizProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let alert = AlertHelper()
    private let db = Firestore.firestore()
    private var businessRef: CollectionReference!
    private let storage = Storage.storage()
    private var alertController: UIAlertController!
    private var previousHash: String = ""

    var business: BusinessAccount!
    
    private var profileUrl: String = ""
    private var profileImage: UIImage!
    private var profileImageView: UIImageView!
    private var nameTextField: UITextField!
    private var usernameTextField: UITextField!
    private var typeTextField: UITextField!
    private var bioTextField: UITextField!
    private var siteTextField : UITextField!
    private var locationTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        initiateFirestore()
        displayInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = true
//        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.isOpaque = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func initiateFirestore() {
        businessRef = db.collection("businesses")
        previousHash = business.hashDataObject()
    }
    
    func displayInfo() {
        guard let business = business else { return }
        if business.profileUrl != "" {
            if let imageData: UIImage = FCache.getImage(key: business.profileUrl), !FCache.isExpired(business.profileUrl) {
                profileImageView.image = imageData
                profileImage = imageData
            } else {
                let imageUrl = URL(string: business.profileUrl)
                profileImageView.af.setImage(withURL: imageUrl!, placeholderImage: nil, filter: nil, imageTransition: .noTransition) { (response) in
                    guard let imageData = response.value else { return }
                    self.profileImage = imageData
                    FCache.setImage(image: imageData, key: business.profileUrl)
                }
            }
        }
        nameTextField.text = business.name
        usernameTextField.text = business.username
        typeTextField.text = business.type
        bioTextField.text = business.bio
        siteTextField.text = business.website
        locationTextField.text = business.location
    }
    
    private func initialView() {
        let view = EditBizProfileView(frame: self.view.frame)
        self.profileImageView = view.profileImageView
        self.nameTextField = view.nameTextField
        self.usernameTextField = view.usernameTextField
        self.typeTextField = view.typeTextField
        self.bioTextField = view.bioTextField
        self.siteTextField = view.siteTextField
        self.locationTextField = view.locationTextField
        self.view = view
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            profileImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            profileImage = originalImage
        }
        profileImageView.image = profileImage
        deleteProfile().then { (check) in
            if check {
                self.updateProfile()
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func deleteProfile() -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let business = self.business else {
                resolve(false)
                return
            }
            if business.profileUrl != "" {
                self.storage.reference(forURL: business.profileUrl).delete { error in
                    if let error = error {
                        print(error)
                        resolve(false)
                    } else {
                        print("Delete Profile Photo Successful")
                        self.businessRef.document(business.id).updateData([
                            "profileUrl": ""
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                                resolve(false)
                            } else {
                                print("Document successfully written!")
                                self.previousHash = business.hashDataObject()
                                resolve(true)
                            }
                        }
                    }
                }
            } else {
                resolve(true)
            }
        }
    }
    
    private func updateProfile() {
        guard let business = business else { return }
        if profileImage != nil {
            let filename = NSUUID().uuidString
            let uploadData = profileImage.jpegData(compressionQuality: 1.0)
            let storagePhotoName = storage.reference().child("profile_images").child(filename)
            storagePhotoName.putData(uploadData!, metadata: nil) { (metadata, err) in
                if let err = err {
                    print("Failed to upload profile photo \(err)")
                }
                storagePhotoName.downloadURL(completion: { (downloadURL, err) in
                    self.profileUrl = (downloadURL?.absoluteString)!
                    print("This is my URL \(self.profileUrl)")
                    self.businessRef.document(business.id).updateData([
                        "profileUrl": self.profileUrl
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            self.business.profileUrl =  self.profileUrl
                            self.previousHash = self.business.hashDataObject()
                            print("Document successfully written!")
                        }
                    }
                })
                print("Successful")
            }
        }
    }
    
    private func updateBizProfile() -> Promise<Bool> {
        alertController = displaySpinner(title: "Updating")
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.businessRef.document(self.business.id).updateData(self.business.toJSON()) { err in
                if let err = err {
                    print("Updated BizAccount is error: \(err)")
                    self.alertController.dismiss(animated: true, completion: nil)
                    resolve(false)
                } else {
                    let updateJson = Mapper().toJSONString(self.business, prettyPrint: true)!
                    print("Updated BizAccount is completed", updateJson)
                    resolve(true)
                }
            }
        }
    }
    
    @IBAction func handleUploadProfile(_ sender: Any?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let title = NSAttributedString(string: "Upload profile photo", attributes: [NSAttributedString.Key.font: UIFont(name: "Quicksand-Bold", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black])
        alertController.setValue(title, forKey: "attributedMessage")
        if profileImage != nil {
            alertController.addAction(UIAlertAction(title: "Remove current photo", style: .destructive, handler: { (_) in
                self.profileImage = nil
                self.profileImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
                self.deleteProfile().then { (_) in }
            }))
        }
        alertController.addAction(UIAlertAction(title: "Choose from library", style: .default, handler: { (_) in
            let imagePickerController = UIImagePickerController()
            UIImagePickerController.availableMediaTypes(for: .photoLibrary)
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.mediaTypes = ["public.image"]
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func handleName(_ sender: Any?) {
        let controller = EditNameController()
        controller.previousController = self
        controller.business = self.business
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleUsername(_ sender: Any?) {
        let controller = EditUsernameController()
        controller.previousController = self
        controller.business = self.business
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleType(_ sender: Any?) {
        let controller = BizTypeController()
        controller.previousController = self
        controller.isBusiness = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleBio(_ sender: Any?) {
        let controller = EditBioController()
        controller.previousController = self
        controller.business = self.business
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleSite(_ sender: Any?) {
        let controller = EditSiteController()
        controller.previousController = self
        controller.business = self.business
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleLocation(_ sender: Any?) {
        let controller = LocationController()
        controller.previousController = self
        controller.isBusiness = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleDone(_ sender: Any?) {
        let current = business.hashDataObject()
        if previousHash == current {
            self.dismiss(animated: true, completion: nil)
        } else {
            updateBizProfile().then { (_) in
                self.alertController.dismiss(animated: true) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Edit Profile"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
        
        let backBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss(_:)))
        backBarButton.tintColor = UIColor.randevoo.mainBlack
        navigationItem.leftBarButtonItem = backBarButton
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone(_:)))
        doneBarButton.tintColor = UIColor.randevoo.mainColor
        navigationItem.rightBarButtonItem = doneBarButton

        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges { (context) in
                print("Is cancelled: \(context.isCancelled)")
            }
        }
    }
}
