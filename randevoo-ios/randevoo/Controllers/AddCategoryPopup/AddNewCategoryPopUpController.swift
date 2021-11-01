//
//  AddNewPopupController.swift
//  randevoo
//
//  Created by Xell on 3/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class AddNewCategoryPopUpController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.randevoo.mainLight
        setupNavItems()
        initialView()
    }
    
    func initialView() {
        let view = AddNewCategoryPopUpView(frame: self.view.frame)
        self.view = view
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "ADD NEW CATEGORY"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
    }

}
