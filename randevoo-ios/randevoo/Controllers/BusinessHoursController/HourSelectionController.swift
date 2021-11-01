//
//  HourSelectionController.swift
//  randevoo
//
//  Created by Alexander on 7/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

class HourSelectionController: UIViewController {
    
    var previousController: UIViewController!
    
    var indexPath: Int = 0
    var openTime: String = "00:00"
    var closeTime: String = "17:00"
    var isOpen: Bool = true
    var isRepeat: Bool = false
    
    private var timeValue: String = "17:00"
    
    private var timePicker: UIDatePicker!
    private var repeatSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        setupTimeRange()
    }
    
    private func initialView() {
        let view = HourSelectionView(frame: self.view.frame)
        self.timePicker = view.timePicker
        self.repeatSwitch = view.repeatSwitch
        self.view = view
        if isOpen {
            view.timeLabel.text = "Open Time"
        } else {
            view.timeLabel.text = "Close Time"
        }
    }
    
    @IBAction func hanleTimePicker(sender: UIDatePicker) {
        let date = sender.date
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeValue = formatter.string(from: date)
    }
    
    @IBAction func handleRepeatSwitch(_ sender: Any?) {
        repeatSwitch.setOn(!repeatSwitch.isOn, animated: true)
    }
    
    @IBAction func handleApply(_ sender: Any?) {
        isRepeat = repeatSwitch.isOn
        let controller = previousController as! BusinessHoursController
        if !isRepeat {
            let businessHour = controller.businessHours[indexPath]
            let bizHour = controller.currentBizPeriod.bizHours[indexPath]
            if isOpen {
                businessHour.openTime = timeValue
                bizHour.openTime = timeValue
            } else {
                businessHour.closeTime = timeValue
                bizHour.closeTime = timeValue
            }
            controller.businessHours[indexPath] = businessHour
            controller.currentBizPeriod.bizHours[indexPath] = bizHour
        } else {
            for i in controller.businessHours {
                if isOpen {
                    i.openTime = timeValue
                } else {
                    i.closeTime = timeValue
                }
            }
            for i in controller.currentBizPeriod.bizHours {
                if isOpen {
                    i.openTime = timeValue
                } else {
                    i.closeTime = timeValue
                }
            }
        }
        self.dismiss(animated: true) {
            controller.businessHoursCollectionView.reloadData()
        }
    }
    
    
    private func setupTimeRange() {
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        // guard let timeZone = TimeZone(identifier: "UTC") else { return }
        // calendar.timeZone = timeZone
        var hour = Calendar.current.component(.hour, from: currentDate)
        var minute = Calendar.current.component(.minute, from: currentDate)
        
        var minimumDate: Date!
        var maximumDate: Date!
        var currentLoad: Date!
        
        if isOpen {
            timeValue = openTime
            hour = openTime.fetchHour()
            minute = openTime.fetchMinute()
            currentLoad = calendar.date(from: DateComponents(hour: hour, minute: minute))!
            hour = closeTime.fetchHour()
            minute = closeTime.fetchMinute()
            maximumDate = calendar.date(from: DateComponents(hour: hour, minute: minute))!
            timePicker.maximumDate = maximumDate
        } else {
            timeValue = closeTime
            hour = closeTime.fetchHour()
            minute = closeTime.fetchMinute()
            currentLoad = calendar.date(from: DateComponents(hour: hour, minute: minute))!
            hour = openTime.fetchHour()
            minute = openTime.fetchMinute()
            minimumDate = calendar.date(from: DateComponents(hour: hour, minute: minute))!
            timePicker.minimumDate = minimumDate
        }
        timePicker.setDate(currentLoad, animated: true)
        
    }
}
