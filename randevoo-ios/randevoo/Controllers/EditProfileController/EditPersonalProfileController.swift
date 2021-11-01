//
//  EditPersonalProfileController.swift
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

class EditPersonalProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let alert = AlertHelper()
    private let db = Firestore.firestore()
    private var personalRef: CollectionReference!
    private let storage = Storage.storage()
    private var alertController: UIAlertController!
    private var previousHash: String = ""
    
    var personal: PersonalAccount!
    
    private var profileUrl: String = ""
    private var profileImage: UIImage!
    private var profileImageView: UIImageView!
    private var nameTextField: UITextField!
    private var usernameTextField: UITextField!
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
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.isOpaque = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func initiateFirestore() {
        personalRef = db.collection("users")
        previousHash = personal.hashDataObject()
    }
    
    func displayInfo() {
        guard let personal = personal else { return }
        if personal.profileUrl != "" {
            if let imageData: UIImage = FCache.getImage(key: personal.profileUrl), !FCache.isExpired(personal.profileUrl) {
                profileImageView.image = imageData
                profileImage = imageData
            } else {
                let imageUrl = URL(string: personal.profileUrl)
                profileImageView.af.setImage(withURL: imageUrl!, placeholderImage: nil, filter: nil, imageTransition: .noTransition) { (response) in
                    guard let imageData = response.value else { return }
                    self.profileImage = imageData
                    FCache.setImage(image: imageData, key: personal.profileUrl)
                }
            }
        }
        nameTextField.text = personal.name
        usernameTextField.text = personal.username
        bioTextField.text = personal.bio
        siteTextField.text = personal.website
        locationTextField.text = personal.location
    }
    
    private func initialView() {
        let view = EditPersonalProfileView(frame: self.view.frame)
        self.profileImageView = view.profileImageView
        self.nameTextField = view.nameTextField
        self.usernameTextField = view.usernameTextField
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
            guard let personal = self.personal else {
                resolve(false)
                return
            }
            if personal.profileUrl != "" {
                self.storage.reference(forURL: personal.profileUrl).delete { error in
                    if let error = error {
                        print(error)
                        resolve(false)
                    } else {
                        print("Delete Profile Photo Successful")
                        self.personalRef.document(personal.id).updateData([
                            "profileUrl": ""
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                                resolve(false)
                            } else {
                                print("Document successfully written!")
                                self.previousHash = personal.hashDataObject()
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
        guard let personal = personal else { return }
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
                    self.personalRef.document(personal.id).updateData([
                        "profileUrl": self.profileUrl
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            self.personal.profileUrl =  self.profileUrl
                            self.previousHash = self.personal.hashDataObject()
                            print("Document successfully written!")
                        }
                    }
                })
                print("Successful")
            }
        }
    }
    
    private func updatePersonalProfile() -> Promise<Bool> {
        alertController = displaySpinner(title: "Updating")
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.personalRef.document(self.personal.id).updateData(self.personal.toJSON()) { err in
                if let err = err {
                    print("Updated PersonalAccount is error: \(err)")
                    self.alertController.dismiss(animated: true, completion: nil)
                    resolve(false)
                } else {
                    let updateJson = Mapper().toJSONString(self.personal, prettyPrint: true)!
                    print("Updated PersonalAccount is completed", updateJson)
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
        controller.personal = self.personal
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleUsername(_ sender: Any?) {
        let controller = EditUsernameController()
        controller.previousController = self
        controller.personal = self.personal
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleBio(_ sender: Any?) {
        let controller = EditBioController()
        controller.previousController = self
        controller.personal = self.personal
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleSite(_ sender: Any?) {
        let controller = EditSiteController()
        controller.previousController = self
        controller.personal = self.personal
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleLocation(_ sender: Any?) {
        let controller = LocationController()
        controller.previousController = self
        controller.isBusiness = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func handleDone(_ sender: Any?) {
        let current = personal.hashDataObject()
        if previousHash == current {
            self.dismiss(animated: true, completion: nil)
        } else {
            updatePersonalProfile().then { (_) in
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
    }
}
