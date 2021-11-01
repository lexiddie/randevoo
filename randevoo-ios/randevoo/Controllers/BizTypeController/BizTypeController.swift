//
//  BizTypeController.swift
//  randevoo
//
//  Created by Lex on 7/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class BizTypeController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var isBusiness: Bool = false
    var previousController: UIViewController!
    
    private let bizTypeTableCell = "bizTypeTableCell"
    private var bizTypeTableView: UITableView!
    private var bizTypes: [BizType] = []
    
    private var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        setupNavItems()
        initialTableView()
        fetchBusinessTypes()
    }
    
    private func initialView() {
        let view = BizTypeView(frame: self.view.frame)
        self.bizTypeTableView = view.bizTypeTableView
        self.searchTextField = view.searchTextField
        self.view = view
        self.searchTextField.delegate = self
    }
    
    private func initialTableView() {
        bizTypeTableView.delegate = self
        bizTypeTableView.dataSource = self
        bizTypeTableView.register(BizTypeCell.self, forCellReuseIdentifier: bizTypeTableCell)
    }
    
    private func fetchBusinessTypes() {
        bizTypes = Mapper<BizType>().mapArray(JSONfile: "BusinessTypes.json")!
        bizTypes = bizTypes.sorted(by: {$0.name < $1.name})
        bizTypeTableView.reloadData()
    }
    
    private func filterBusinessTypes(search: String) {
        bizTypes = bizTypes.filter({
            return $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().contains(search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
        })
        bizTypeTableView.reloadData()
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        guard let searchText = textField.text else {  return }
        filterBusinessTypes(search: searchText)

        if searchText.isEmpty || searchText == "" {
            print("It's empty")
            fetchBusinessTypes()
        }
    }
    
    private func setupNavItems() {
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone(_:)))
        doneBarButton.tintColor = UIColor.randevoo.mainBlack
        navigationItem.rightBarButtonItem = doneBarButton
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchTextField)
        searchTextField.snp.makeConstraints{ (make) in
            make.height.equalTo(35)
            make.width.equalTo(self.view.frame.width - 90)
        }
        searchTextField.isEnabled = true
        
        if isBusiness {
            navigationItem.hidesBackButton = true
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}

extension BizTypeController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bizTypes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: bizTypeTableCell, for: indexPath) as! BizTypeCell
        cell.nameLabel.text = bizTypes[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = bizTypes[indexPath.row].name
        if !isBusiness, let controller = previousController as? CreateBizAccountController {
            controller.businessType = type
            controller.businessTypeTextField.text = type
            self.dismiss(animated: true, completion: nil)
        } else if isBusiness, let controller = previousController as? EditBizProfileController {
            controller.business.type = type
            controller.displayInfo()
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func handleDone(_ sender: Any?) {
        if isBusiness {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
