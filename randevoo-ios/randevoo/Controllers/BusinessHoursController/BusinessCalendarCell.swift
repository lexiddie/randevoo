//
//  BusinessCalendarCell.swift
//  randevoo
//
//  Created by Alexander on 6/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit
import HorizonCalendar

private enum CalendarSelection {
    case singleDay(Day)
    case dayRange(DayRange)
}

class BusinessCalendarCell: UICollectionViewCell {
    
    var bizPeriod: BizPeriod? {
        didSet {
            guard let period = bizPeriod else { return }
            dateRangeTextField.text = period.bizRange.label
            durationTextField.text = period.bizTimeslot.label
            availabilityTextField.text = period.bizAvailability.label
            initialCalendarView()
        }
    }
    
    private let timestampHelper = TimestampHelper()
    
    private var calendarSelection: CalendarSelection?
    private var selectedDay: Day?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func initialCalendarView() {
        let newContent = self.makeContent()
        calendarView.setContent(newContent)
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let currentDay = Calendar.current.component(.day, from: currentDate)
        let july2020 = Calendar.current.date(from: DateComponents(year: currentYear, month: currentMonth, day: currentDay))!
        calendarView.scroll(
            toDayContaining: july2020,
            scrollPosition: .centered,
            animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(dateRangeLabel)
        dateRangeLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(self.safeAreaLayoutGuide).inset(30)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(dateRangeTextField)
        dateRangeTextField.snp.makeConstraints{ (make) in
            make.top.equalTo(dateRangeLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(dateRangeButton)
        dateRangeButton.snp.makeConstraints{ (make) in
            make.top.equalTo(dateRangeLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        
        addSubview(durationLabel)
        durationLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(dateRangeTextField.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(durationTextField)
        durationTextField.snp.makeConstraints{ (make) in
            make.top.equalTo(durationLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(durationButton)
        durationButton.snp.makeConstraints{ (make) in
            make.top.equalTo(durationLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        
        addSubview(availabilityLabel)
        availabilityLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(durationTextField.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(availabilityTextField)
        availabilityTextField.snp.makeConstraints{ (make) in
            make.top.equalTo(availabilityLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        addSubview(availabilityButton)
        availabilityButton.snp.makeConstraints{ (make) in
            make.top.equalTo(availabilityLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
        }
        
        addSubview(calendarView)
        calendarView.snp.makeConstraints { (make) in
            make.top.equalTo(availabilityTextField.snp.bottom).offset(10)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.bottom.equalTo(self)
        }
    }
    
    let dateRangeLabel: UILabel = {
        let label = UILabel()
        label.text = "Select date range"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let dateRangeTextField: UITextField = {
        let textField = UITextField(placeholder: "Business date range", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .default)
        textField.text = "One Week"
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.randevoo.mainColor
        textField.isEnabled = false
        return textField
    }()
    
    let dateRangeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(BusinessHoursController.handleDateRange(_:)), for: .touchUpInside)
        return button
    }()
    
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Select duration per timeslot"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let durationTextField: UITextField = {
        let textField = UITextField(placeholder: "Business duration", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .default)
        textField.text = "30 Minutes"
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.randevoo.mainColor
        textField.isEnabled = false
        return textField
    }()
    
    let durationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(BusinessHoursController.handleDuration(_:)), for: .touchUpInside)
        return button
    }()
    
    let availabilityLabel: UILabel = {
        let label = UILabel()
        label.text = "Select availability per timeslot"
        label.font = UIFont(name: "Quicksand-Bold", size: 17)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let availabilityTextField: UITextField = {
        let textField = UITextField(placeholder: "Business availability", placeholderColor: UIColor.randevoo.mainLightGray.withAlphaComponent(0.8), keyboardType: .default)
        textField.text = "1 Time"
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.randevoo.mainColor
        textField.isEnabled = false
        return textField
    }()
    
    let availabilityButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0
        button.layer.backgroundColor = UIColor.clear.cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.addTarget(self, action: #selector(BusinessHoursController.handleAvailability(_:)), for: .touchUpInside)
        return button
    }()
    
    private func getStartEndDate() -> (Date, Date) {
        guard let period = bizPeriod else { return (Date(), Date()) }
        let rangeWeeks = [DateRange.oneWeek, DateRange.twoWeek, DateRange.threeWeek]
        let rangeMonths = [DateRange.oneMonth, DateRange.twoMonth, DateRange.threeMonth]
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let year = Calendar.current.component(.year, from: now)
        let month = Calendar.current.component(.month, from: now)
        let day = Calendar.current.component(.day, from: now)
        let start = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        var end = Date()
        if rangeWeeks.contains(where: {$0.rawValue == period.bizRange.label}) {
            end = calendar.date(from: DateComponents(year: year, month: month, day: day + Int(period.bizRange.value)))!
        } else if rangeMonths.contains(where: {$0.rawValue == period.bizRange.label}) {
            end = calendar.date(from: DateComponents(year: year, month: month + Int(period.bizRange.value), day: day))!
        }
        return (start, end)
    }
     
    lazy var calendarView = CalendarView(initialContent: makeContent())
    
    lazy var calendar = Calendar.current
    lazy var dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = calendar.locale
        dateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "EEEE, MMM d, yyyy",
            options: 0,
            locale: calendar.locale ?? Locale.current)
        return dateFormatter
    }()
}
extension BusinessCalendarCell {
    
    private func makeContent() -> CalendarViewContent {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let currentDay = Calendar.current.component(.day, from: currentDate)
        let (_, end) = getStartEndDate()
        let ED = timestampHelper.DateWithHyphen(date: end).split(separator: "-")
        var startDayRange = 0
        let endDay = Int(ED[0])
        let endMonth = Int(ED[1])
        let endYear = Int(ED[2])
        let startDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: currentDay))!
        let endDate = calendar.date(from: DateComponents(year: endYear, month: endMonth, day: endDay))!
        let dateRange = startDate...endDate
        let selectedDay = self.selectedDay
        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions()))
            .withInterMonthSpacing(25)
            .withVerticalDayMargin(10)
            .withHorizontalDayMargin(10)
            .withDayRangeItemModelProvider(for: [dateRange]) { dayRangeLayoutContext in
                CalendarItemModel<DayRangeIndicatorView>(
                  invariantViewProperties: .init(indicatorColor: UIColor.black.withAlphaComponent(0.15)),
                  viewModel: .init(framesOfDaysToHighlight: dayRangeLayoutContext.daysAndFrames.map { $0.frame }))
              }
            .withDayItemModelProvider{
                day in
                var invariantViewProperties = DayLabel.InvariantViewProperties(
                    font: UIFont.systemFont(ofSize: 18),
                    textColor: .black,
                    backgroundColor: .clear)
                if (day.day == currentDay && day.month.month == currentMonth && day.month.year == currentYear) || (day.day == endDay  && day.month.month == endMonth! && day.month.year == endYear!){
                    invariantViewProperties.textColor = .white
                    invariantViewProperties.backgroundColor = .black
                } else if day.day < currentDay && day.month.month <= currentMonth && day.month.year <= currentYear || day.day > endDay! && day.month.month >= endMonth! && day.month.year >= endYear! {
                    invariantViewProperties.textColor = .lightGray
                    invariantViewProperties.backgroundColor = .white
                }
                self.calendarView.daySelectionHandler = { [weak self] day in
                    guard let self = self else { return }

                self.selectedDay = day
                let newContent = self.makeContent()
                self.calendarView.setContent(newContent)
              }
                  return CalendarItemModel<DayLabel>(
                    invariantViewProperties: invariantViewProperties,
                    viewModel: .init(day: day))
        }
    }
    
}
