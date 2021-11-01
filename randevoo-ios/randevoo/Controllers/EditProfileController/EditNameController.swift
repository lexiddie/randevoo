//
//  EditNameController.swift
//  randevoo
//
//  Created by Alexander on 11/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class EditNameController: UIViewController {
    
    var previousController: UIViewController!
    var personal: PersonalAccount!
    var business: BusinessAccount!
    
    private var nameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        displayPersonal()
        displayBusiness()
    }
    
    private func initialView() {
        let view = EditNameView(frame: self.view.frame)
        self.nameTextField = view.nameTextField
        self.view = view
    }
    
    private func displayPersonal() {
        guard let personal = personal else { return }
        nameTextField.text = personal.name
    }
    
    private func displayBusiness() {
        guard let business = business else { return }
        nameTextField.text = business.name
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleDone(_ sender: Any?) {
        let name = self.nameTextField.text! as String
        if isPersonalAccount {
            let controller = previousController as! EditPersonalProfileController
            controller.personal.name = name
            controller.displayInfo()
            navigationController?.popViewController(animated: true)
        } else {
            let controller = previousController as! EditBizProfileController
            controller.business.name = name
            controller.displayInfo()
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Name"
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
