//
//  PickerSelectionController.swift
//  randevoo
//
//  Created by Alexander on 7/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class PickerSelectionController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var previousController: UIViewController!
    var bizPeriod: BizPeriod!
    var currentSelect: Int = 0
    
    var isBusinessRange: Bool = false
    var isBusinessTimeslot: Bool = false
    var isBusinessAvailability: Bool = false
    
    var businessRanges: [BusinessRange] = []
    var businessTimeslots: [BusinessTimeslot] = []
    var businessAvailabilities: [BusinessAvailability] = []

    private var selectionPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        loadedCurrent()
    }
    
    private func initialView() {
        let view = PickerSelectionView(frame: self.view.frame)
        self.selectionPickerView = view.selectionPickerView
        self.view = view
        self.selectionPickerView.delegate = self
        self.selectionPickerView.dataSource = self
    }
    
    private func loadedCurrent() {
        currentSelect = 0
        if isBusinessRange {
            currentSelect = findBizRange()
        } else if isBusinessTimeslot {
            currentSelect = findBizTimeslot()
        } else {
            currentSelect = findBizAvailability()
        }
        self.selectionPickerView?.selectRow(currentSelect, inComponent: 0, animated: true)
    }
    
    private func findBizRange() -> Int {
        for (index, element) in businessRanges.enumerated() {
            if element.dateRange.rawValue == bizPeriod.bizRange.label {
                return index
            }
        }
        return 0
    }
    
    private func findBizTimeslot() -> Int {
        for (index, element) in businessTimeslots.enumerated() {
            if element.timeRange.rawValue == bizPeriod.bizTimeslot.label {
                return index
            }
        }
        return 0
    }
    
    private func findBizAvailability() -> Int {
        for (index, element) in businessAvailabilities.enumerated() {
            if element.label == bizPeriod.bizAvailability.label {
                return index
            }
        }
        return 0
    }
    
    @IBAction func handleSelect(_ sender: Any?) {
        let controller = previousController as! BusinessHoursController
        if isBusinessRange {
            let current = businessRanges[currentSelect]
            let bizRange = Period(label: current.dateRange.rawValue, value: current.value)
            controller.currentBizPeriod.bizRange = bizRange
            controller.businessHoursCollectionView.reloadData()
        } else if isBusinessTimeslot {
            let current = businessTimeslots[currentSelect]
            let bizTimeslot = Period(label: current.timeRange.rawValue, value: current.value)
            controller.currentBizPeriod.bizTimeslot = bizTimeslot
        } else {
            let current = businessAvailabilities[currentSelect]
            let bizAvailability = Period(label: current.label, value: current.value)
            controller.currentBizPeriod.bizAvailability = bizAvailability
        }
        self.dismiss(animated: true) {
            controller.businessHoursCollectionView.reloadData()
        }
    }
}

extension PickerSelectionController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isBusinessRange {
            return businessRanges.count
        } else if isBusinessTimeslot {
            return businessTimeslots.count
        } else {
            return businessAvailabilities.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if isBusinessRange {
            let row = businessRanges[row].dateRange.rawValue
            return row
        } else if isBusinessTimeslot {
            let row = businessTimeslots[row].timeRange.rawValue
            return row
        } else {
            let row = businessAvailabilities[row].label
            return row
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentSelect = row
        if isBusinessRange {
            print(businessRanges[row].dateRange.rawValue)
        } else if isBusinessTimeslot {
            print(businessTimeslots[row].timeRange.rawValue)
        } else {
            print(businessAvailabilities[row].label)
        }
    }
}
