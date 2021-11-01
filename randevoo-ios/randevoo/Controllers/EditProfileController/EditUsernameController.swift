//
//  EditUsernameController.swift
//  randevoo
//
//  Created by Alexander on 11/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON
import FirebaseFirestore

class EditUsernameController: UIViewController {
    
    private let alertHelper = AlertHelper()
    private let usersProvider = UsersProvider()
    
    var previousController: UIViewController!
    var personal: PersonalAccount!
    var business: BusinessAccount!
    
    private var usernameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        displayPersonal()
        displayBusiness()
    }
    
    private func initialView() {
        let view = EditUsernameView(frame: self.view.frame)
        self.usernameTextField = view.usernameTextField
        self.view = view
    }
    
    private func displayPersonal() {
        guard let personal = personal else { return }
        usernameTextField.text = personal.username
    }
    
    private func displayBusiness() {
        guard let business = business else { return }
        usernameTextField.text = business.username
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleDone(_ sender: Any?) {
        var username = self.usernameTextField.text! as String
        username = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if username.isEmpty || username == "" {
            self.alertHelper.showAlert(title: "Invalid Username", alert: "Your username must be empty", controller: self)
        } else if isPersonalAccount {
            let controller = previousController as! EditPersonalProfileController
            if personal.username == username || personalAccount?.username == username {
                controller.personal.username = username
                controller.displayInfo()
                navigationController?.popViewController(animated: true)
            } else {
                usersProvider.checkAvailability(username: username).then { (check) in
                    if check {
                        self.alertHelper.showAlert(title: "Invalid Username", alert: "Your selected username is already existed!", controller: self)
                    } else {
                        controller.personal.username = username
                        controller.displayInfo()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            let controller = previousController as! EditBizProfileController
            if business.username == username || businessAccount?.username == username {
                controller.business.username = username
                controller.displayInfo()
                navigationController?.popViewController(animated: true)
            } else {
                usersProvider.checkAvailability(username: username).then { (check) in
                    if check {
                        self.alertHelper.showAlert(title: "Invalid Username", alert: "Your selected username is already existed!", controller: self)
                    } else {
                        controller.business.username = username
                        controller.displayInfo()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Username"
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
        backButton.backgroundColor = UIColor.clear
        backButton.layer.cornerRadius = 8
        backButton.addTarget(self, action: #selector(handleBack(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.snp.makeConstraints{ (make) in
           make.height.width.equalTo(40)
        }
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone(_:)))
        doneBarButton.tintColor = UIColor.randevoo.mainColor
        navigationItem.rightBarButtonItem = doneBarButton
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

}
