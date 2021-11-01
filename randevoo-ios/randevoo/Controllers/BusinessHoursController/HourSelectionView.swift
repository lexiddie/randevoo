//
//  HourSelectionView.swift
//  randevoo
//
//  Created by Alexander on 7/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

class HourSelectionView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
            make.left.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(timePicker)
        timePicker.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
            make.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(repeatLabel)
        repeatLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(80)
            make.height.equalTo(50)
            make.left.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(repeatSwitch)
        repeatSwitch.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(80)
            make.height.equalTo(50)
            make.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(4)
            make.width.equalTo(40)
        }
        addSubview(applyButton)
        applyButton.snp.makeConstraints{ (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
    }
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Time"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainColor
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    let timePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.time
        datePicker.backgroundColor = UIColor.clear
        datePicker.tintColor = UIColor.randevoo.mainColor
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.minuteInterval = 30
        datePicker.sizeToFit()
        datePicker.addTarget(self, action: #selector(HourSelectionController.hanleTimePicker), for: .allEvents)
        return datePicker
    }()
    
    let repeatLabel: UILabel = {
        let label = UILabel()
        label.text = "Repeat Everyday"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainColor
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    let repeatSwitch: UISwitch = {
        let repeatSwitch = UISwitch()
        repeatSwitch.onTintColor = UIColor.randevoo.mainColor
        repeatSwitch.tintColor = UIColor.randevoo.mainColor
        repeatSwitch.addTarget(self, action:  #selector(HourSelectionController.handleRepeatSwitch(_:)), for: .touchDown)
        return repeatSwitch
    }()
    
    let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainBlueGrey.withAlphaComponent(0.5)
        view.layer.cornerRadius = 2
        return view
    }()
    
    let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 16)
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.setTitle("Apply", for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.randevoo.mainColor
        button.addTarget(self, action: #selector(HourSelectionController.handleApply(_:)), for: .touchUpInside)
        return button
    }()
}
