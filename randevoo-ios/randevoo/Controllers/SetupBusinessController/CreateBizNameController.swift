//
//  CreateBizNameController.swift
//  randevoo
//
//  Created by Lex on 23/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit

class CreateBizNameController: UIViewController {

    var previousController: UIViewController!
    
    private var alertHelper = AlertHelper()
    
    private var businessName: String!
    private var businessNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
    }
    
    private func initialView() {
        let view = CreateBizNameView(frame: self.view.frame)
        self.businessNameTextField = view.businessNameTextField
        self.view = view
    }
    
    @IBAction func handleNext(_ sender: Any?) {
        if (businessNameTextField.text?.isEmpty)! {
            alertHelper.showAlert(title: "Invalid Input", alert: "Business name must not be empty", controller: self)
        } else {
            let controller = CreateBizInfoController()
            self.businessName = self.businessNameTextField.text! as String
            controller.previousController = previousController
            controller.businessName = businessName
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Create business account"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
        
        let backBarButton = UIBarButtonItem(image: UIImage(named: "ArrowLeft")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss(_:)))
        navigationItem.leftBarButtonItem = backBarButton
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    }
}
