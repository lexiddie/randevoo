//
//  LocationController.swift
//  randevoo
//
//  Created by Lex on 1/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class LocationController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var isCreate: Bool = false
    var isBusiness: Bool = false
    var previousController: UIViewController!
    let locationPointHelper = LocationPointHelper()
    
    let locationTableCell = "locationTableCell"
    var locationTableView: UITableView!
    var locationPoint: LocationPoint!
    
    private var searchTextField: UITextField!
    
    // Has bug during filter will be fixed later
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        setupNavItems()
        initialTableView()
        fetchLocationPoint()
    }
    
    private func initialView() {
        let view = LocationView(frame: self.view.frame)
        self.locationTableView = view.locationTableView
        self.searchTextField = view.searchTextField
        self.view = view
        self.searchTextField.delegate = self
    }
    
    private func initialTableView() {
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.register(LocationTableCell.self, forCellReuseIdentifier: locationTableCell)
    }
    
    private func fetchLocationPoint() {
        locationPoint = locationPointHelper.getCurrentLocationPoint(country: "Thailand")
        locationTableView.reloadData()
    }
    
    private func filterLocationPoint(search: String) {
        locationPoint.regions = locationPoint.regions.filter({
            return $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().contains(search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
        })
        locationTableView.reloadData()
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        guard let searchText = textField.text else {  return }
        filterLocationPoint(search: searchText)

        if searchText.isEmpty || searchText == "" {
            print("It's empty")
            fetchLocationPoint()
        }
    }
    
    @IBAction func handleDone(_ sender: Any?) {
        if !isCreate {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
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
        
        if !isCreate {
            navigationItem.hidesBackButton = true
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}


extension LocationController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationPoint.regions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: locationTableCell, for: indexPath) as! LocationTableCell
        cell.nameLabel.text = "\(String(locationPoint.regions[indexPath.row].name)), \(String(locationPoint.name))"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = "\(String(locationPoint.regions[indexPath.row].name)), \(String(locationPoint.name))"
        if isCreate, let controller = previousController as? CreateBizInfoController {
            controller.location = location
            controller.locationTextField.text = location
            self.dismiss(animated: true, completion: nil)
        } else if isBusiness, let controller = previousController as? EditBizProfileController {
            controller.business.location = location
            controller.displayInfo()
            navigationController?.popViewController(animated: true)
        } else if !isBusiness, let controller = previousController as? EditPersonalProfileController {
            controller.personal.location = location
            controller.displayInfo()
            navigationController?.popViewController(animated: true)
        }
    }
}
