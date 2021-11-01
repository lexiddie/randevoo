//
//  BusinessHoursCell.swift
//  randevoo
//
//  Created by Alexander on 6/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

protocol BusinessHoursCellDelegate {
    
    func didSelectDate(for cell: BusinessHoursCell)
    
    func didOpenHour(for cell: BusinessHoursCell)
    
    func didCloseHour(for cell: BusinessHoursCell)
}

class BusinessHoursCell: UICollectionViewCell {
    
    var delegate: BusinessHoursCellDelegate?
    
    var businessHour: BusinessHour? {
        didSet {
            guard let hour = businessHour else { return }
            
            dateLabel.text = hour.businessDate.rawValue
            if hour.isActive {
                dateLabel.textColor = UIColor.white
                dateLabel.layer.backgroundColor = UIColor.randevoo.mainColor.cgColor
                
                closedStackView.isHidden = true
                businessHoursStackView.isHidden = false
                businessSelectStackView.isHidden = false
            } else {
                dateLabel.textColor = UIColor.randevoo.mainColor
                dateLabel.layer.backgroundColor = UIColor.white.cgColor
                dateLabel.layer.borderWidth = 0.5
                dateLabel.layer.borderColor = UIColor.randevoo.mainBlueGrey.withAlphaComponent(0.5).cgColor
                
                closedStackView.isHidden = false
                businessHoursStackView.isHidden = true
                businessSelectStackView.isHidden = true
            }
            startLabel.text = hour.openTime
            toLabel.text = hour.closeTime
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.width.equalTo(45)
            make.left.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(dateButton)
        dateButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(50)
            make.width.equalTo(100)
            make.left.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(businessHoursStackView)
        businessHoursStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(50)
            make.width.equalTo(self.frame.width - 160)
            make.right.lessThanOrEqualTo(self).inset(30)
        }
        businessHoursStackView.addArrangedSubview(openStackView)
        businessHoursStackView.addArrangedSubview(closeStackView)
        openStackView.addArrangedSubview(openLabel)
        openStackView.addArrangedSubview(startLabel)
        closeStackView.addArrangedSubview(closeLabel)
        closeStackView.addArrangedSubview(toLabel)
        addSubview(businessSelectStackView)
        businessSelectStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(50)
            make.width.equalTo(self.frame.width - 160)
            make.right.lessThanOrEqualTo(self).inset(30)
        }
        businessSelectStackView.addArrangedSubview(openHourButton)
        businessSelectStackView.addArrangedSubview(closeHourButton)
        
        addSubview(closedStackView)
        closedStackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(50)
            make.width.equalTo((self.frame.width - 160) / 2)
            make.right.lessThanOrEqualTo(self).inset(30)
        }
        closedStackView.addArrangedSubview(closedLabel)
        closedStackView.addArrangedSubview(allDayLabel)
    }
    
    let dateLabel: UILabel = {
        let label = PaddingLabel()
        label.textColor = UIColor.white
        label.layer.backgroundColor = UIColor.randevoo.mainColor.cgColor
        label.layer.cornerRadius = 45/2
        label.font = UIFont(name: "Quicksand-Medium", size: 15)
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor.clear.cgColor
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 1, 0, 1)
        return label
    }()
    
    lazy var dateButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 0
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(handleSelectDate(_:)), for: .touchUpInside)
        return button
    }()
    
    let businessHoursStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    let openLabel: UILabel = {
        let label = UILabel()
        label.text = "OPEN"
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    let startLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainColor
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    let openStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    let closeLabel: UILabel = {
        let label = UILabel()
        label.text = "CLOSE"
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    let toLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainColor
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    let closeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    let businessSelectStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var openHourButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 0
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(handleOpenHour(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var closeHourButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 0
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(handleCloseHour(_:)), for: .touchUpInside)
        return button
    }()
    
    let closedStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = UIColor.randevoo.mainLight
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.isHidden = true
        return stackView
    }()
    
    let closedLabel: UILabel = {
        let label = UILabel()
        label.text = "CLOSED"
        label.font = UIFont(name: "Quicksand-Regular", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    let allDayLabel: UILabel = {
        let label = UILabel()
        label.text = "All Day"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainColor
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        return label
    }()
    
    @IBAction func handleSelectDate(_ sender: Any?) {
        delegate?.didSelectDate(for: self)
    }
    
    @IBAction func handleOpenHour(_ sender: Any?) {
        delegate?.didOpenHour(for: self)
    }
    
    @IBAction func handleCloseHour(_ sender: Any?) {
        delegate?.didCloseHour(for: self)
    }
}
