//
//  BizCalendarView.swift
//  randevoo
//
//  Created by Lex on 9/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMaps
import Alamofire
import AlamofireImage
import Hydra
import HorizonCalendar
import ObjectMapper
import SwiftyJSON

private enum CalendarSelection {
    case singleDay(Day)
    case dayRange(DayRange)
}

protocol BizCalendarViewDelegate {
    func didSelectOnTimeslot(indexSlot: Int)
}

class BizCalendarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var delegate: BizCalendarViewDelegate?
    var width: CGFloat = UIScreen.main.bounds.width
    var bizTimeslots: [String] = []
    var mainController: UIViewController!
    
    private var calendarSelection: CalendarSelection?
    private var selectedDay: Day?
    var previousSelectDay: Day?
    
    private var selectedIndex: Int = 0
    private let bizTimeslotCell = "bizTimeslotCell"
    private let numberFormatter = NumberFormatter()
    
    var availableTime: [TimeDemo] = []
    var timeslots: [Timeslot] = []
    var bizReservations: [BizReservation] = []
    let timestampHelper = TimestampHelper()
    var currentBizPeriod: BizPeriod!
    var unAvailableHour:[Int] = []
    var selectDate = ""
    var businessId = ""
    var isFirstLoad = true
    var endDayInRange = 0
    let monthValue = MonthValue()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        initiateCollectionView()
        loadFriendlyLabel()
        retrieveDate()
        print("unAvailableHour", JSON(unAvailableHour))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(calendarView)
        calendarView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self).inset(20)
            make.height.equalTo(330)
        }
        addSubview(selectedDateLabel)
        selectedDateLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(calendarView.snp.bottom).offset(5)
            make.left.right.equalTo(self).inset(20)
            make.height.equalTo(35)
            make.centerX.equalTo(self)
        }
        addSubview(timeslotCollectionView)
        timeslotCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(calendarView.snp.bottom).offset(50)
            make.centerX.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
            make.bottom.equalTo(self)
        }
        addSubview(friendlyLabel)
        friendlyLabel.snp.makeConstraints{ (make) in
            make.left.right.equalTo(timeslotCollectionView).inset(30)
            make.center.equalTo(timeslotCollectionView)
        }
    }
    
    private func initiateCollectionView() {
        timeslotCollectionView.delegate = self
        timeslotCollectionView.dataSource = self
        timeslotCollectionView.register(BizTimeslotCell.self, forCellWithReuseIdentifier: bizTimeslotCell)
        timeslotCollectionView.keyboardDismissMode = .onDrag
    }
    
    func loadFriendlyLabel() {
        if availableTime.count == 0 {
            friendlyLabel.text = "No timeslots to show😴"
        } else {
            friendlyLabel.text = nil
        }
    }
    
    private func updateSelectDate(date: Date = Date()) {
        selectedDateLabel.text = timestampHelper.toDateStandard(date: date)
    }
    
    lazy var calendarView = CalendarView(initialContent: makeContent())
    
    lazy var timeslotCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        return collectionView
    }()
    
    let friendlyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textColor = UIColor.randevoo.mainBlack
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    let selectedDateLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.randevoo.mainColor.cgColor
        label.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Bold", size: 18)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 10, 0, 10)
        return label
    }()
    
    //Generate Timeslot
    
    func retrieveDate() {
        self.currentBizPeriod = gBizPeriod
        for time in currentBizPeriod.bizHours {
            if !time.isActive {
                if time.dateLabel == "SUN" {
                    unAvailableHour.append(1)
                } else if time.dateLabel == "MON" {
                    unAvailableHour.append(2)
                }else if time.dateLabel == "TUE" {
                    unAvailableHour.append(3)
                }else if time.dateLabel == "WED" {
                    unAvailableHour.append(4)
                }else if time.dateLabel == "THU" {
                    unAvailableHour.append(5)
                }else if time.dateLabel == "FRI" {
                    unAvailableHour.append(6)
                }else {
                    unAvailableHour.append(7)
                }
                
            }
        }
        print(unAvailableHour)
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
    
    
    private func createAvailableTime(timeslot: BizPeriod, day: Int, date: String, dayCalendar: Day) {
        let currentDate = Date()
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let currentDay = Calendar.current.component(.day, from: currentDate)
        let thisTime = timestampHelper.toTimeShort(date: currentDate)
        let currentHour = thisTime.fetchHour()
        let currentMinute = thisTime.fetchMinute()
        availableTime.removeAll()
        let currentTime: BizHour!
        if day == 1 {
            let found = timeslot.bizHours.filter({$0.dateLabel == "SUN"})
            currentTime = found[0]
        } else if day == 2 {
            let found = timeslot.bizHours.filter({$0.dateLabel == "MON"})
            currentTime = found[0]
        } else if day == 3 {
            let found = timeslot.bizHours.filter({$0.dateLabel == "TUE"})
            currentTime = found[0]
        } else if day == 4 {
            let found = timeslot.bizHours.filter({$0.dateLabel == "WED"})
            currentTime = found[0]
        } else if day == 5 {
            let found = timeslot.bizHours.filter({$0.dateLabel == "THU"})
            currentTime = found[0]
        } else if day == 6 {
            let found = timeslot.bizHours.filter({$0.dateLabel == "FRI"})
            currentTime = found[0]
        } else {
            let found = timeslot.bizHours.filter({$0.dateLabel == "SAT"})
            currentTime = found[0]
        }
        let time = currentTime.openTime.split(separator: ":")
        var startHour = Double(time[0])!
        var startTime = setTimeToDouble(time: currentTime.openTime)
        let endTime = setTimeToDouble(time: currentTime.closeTime)
        var gap = Double(timeslot.bizTimeslot.value)
        var previousGap = 0.0
        while startTime <= endTime {
            if startTime.truncatingRemainder(dividingBy: startHour) == 0 && gap != 0.5 && previousGap != 0.5  {
                let timeString = String(Int(startTime)) + ":00 - " + String(Int(startTime + gap)) + ":00"
                createAvailableTimeForDisplay(timeString: timeString, date: date, startTime: startTime, gap: gap, endTime: endTime, dayCalendar: dayCalendar, currentMonth: currentMonth, currentDay: currentDay, currentHour: currentHour, currentMinute: currentMinute)
                startTime += gap
                startHour += gap
            } else if startHour < startTime && startTime <  (startHour + 1.0) && gap != 0.5 && previousGap != 0.5  {
                let timeString = String(Int(startTime)) + ":30 - " + String(Int(startTime + gap)) + ":30"
                createAvailableTimeForDisplay(timeString: timeString, date: date, startTime: startTime + 0.5, gap: gap, endTime: endTime, dayCalendar: dayCalendar, currentMonth: currentMonth, currentDay: currentDay, currentHour: currentHour, currentMinute: currentMinute)
                startTime += gap
                startHour += gap
            } else if startHour < startTime && startTime <  (startHour + 1.0) && (gap == 0.5 || previousGap == 0.5)  {
                if gap == 0.5 {
                    let timeString = String(Int(startTime)) + ":30 - " + String(Int(startTime + 1)) + ":00"
                    createAvailableTimeForDisplay(timeString: timeString, date: date, startTime: startTime + 0.5, gap: gap, endTime: endTime, dayCalendar: dayCalendar, currentMonth: currentMonth, currentDay: currentDay, currentHour: currentHour, currentMinute: currentMinute)
                    startTime += 1
                    startHour += 1
                    previousGap = 0.5
                    gap = 1.0
                } else if  previousGap == 0.5 {
                    let timeString = String(Int(startTime)) + ":00 - " + String(Int(startTime)) + ":30"
                    createAvailableTimeForDisplay(timeString: timeString, date: date, startTime: startTime, gap: gap, endTime: endTime, dayCalendar: dayCalendar, currentMonth: currentMonth, currentDay: currentDay, currentHour: currentHour, currentMinute: currentMinute)
                    //                    startHour += gap
                    previousGap = 1
                    gap = 0.5
                }
                
            } else if startTime.truncatingRemainder(dividingBy: startHour) == 0 && ( gap == 0.5 || previousGap == 0.5 ) {
                if gap == 0.5 {
                    let timeString = String(Int(startTime)) + ":00 - " + String(Int(startTime)) + ":30"
                    createAvailableTimeForDisplay(timeString: timeString, date: date, startTime: startTime, gap: gap, endTime: endTime, dayCalendar: dayCalendar, currentMonth: currentMonth, currentDay: currentDay, currentHour: currentHour, currentMinute: currentMinute)
                    previousGap = 0.5
                    gap = 1
                } else if  previousGap == 0.5 {
                    let timeString = String(Int(startTime)) + ":30 - " + String(Int(startTime + 1)) + ":00"
                    createAvailableTimeForDisplay(timeString: timeString, date: date, startTime: startTime + 0.5, gap: gap, endTime: endTime, dayCalendar: dayCalendar, currentMonth: currentMonth, currentDay: currentDay, currentHour: currentHour, currentMinute: currentMinute)
                    startTime += 1
                    startHour += 1
                    previousGap = 1
                    gap = 0.5
                }
                
            }
        }
    }
    
    private func setTimeToDouble(time: String) -> Double {
        let time = time.split(separator: ":")
        var timeAsDouble = Double(time[0])!
        let minute = Double(time[1])
        if minute == 30 {
            timeAsDouble += 0.5
        }
        return timeAsDouble
    }
    
    private func createAvailableTimeForDisplay(timeString: String, date: String, startTime: Double, gap: Double, endTime: Double, dayCalendar: Day, currentMonth: Int, currentDay: Int, currentHour: Int, currentMinute: Int ) {
        let newBizAvailability = calculateBizAvailability(dateString: date, timeString: timeString)
        var currentHour = Double(currentHour)
        if currentMinute > 30 {
            currentHour += 0.5
        } else {
            currentHour += 0
        }
        if startTime + gap <= endTime {
            if dayCalendar.month.month == currentMonth && dayCalendar.day == currentDay{
                availableTime.append(TimeDemo(time: timeString, status: "Available", bizAvailability: newBizAvailability ))
            } else {
                availableTime.append(TimeDemo(time: timeString, status: "Available", bizAvailability: newBizAvailability))
            }
        }
    }
    
    private func calculateBizAvailability(dateString: String, timeString: String) -> Int {
        var availability = Int(gBizPeriod!.bizAvailability.value)
        for time in timeslots {
            if time.time == timeString && time.date == dateString && time.isApproved {
                availability -= 1
            }
        }
        return availability
    }
    
    private func setDate(day: Day) -> Int {
        let dateString = String(day.month.year) + "-" + String(day.month.month) + "-" + String(day.day)
        let weekday = Calendar.current.component(.weekday, from: dateString.fetchDateISO!)
        return weekday
    }
    
    
}


extension BizCalendarView {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.width - 2) / 2
        return CGSize(width: width - 15, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableTime.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bizTimeslotCell, for: indexPath) as! BizTimeslotCell
        let thisTime = BizAvailable(time: availableTime[indexPath.row].time, available: availableTime[indexPath.row].bizAvailability!)
        cell.time = thisTime
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = BizIndividualDateController()
        let previousController = mainController as! BizReservationController
        let filterReservation = bizReservations.filter({$0.timeslot.date == selectDate && $0.timeslot.time == availableTime[indexPath.row].time})
        controller.bizReservations = filterReservation
        controller.dateTime = "\(selectDate), \(String(availableTime[indexPath.row].time))"
        previousController.navigationController?.pushViewController(controller, animated: true)
    }
}

extension BizCalendarView {
    
    private func getStartEndDate() -> (Date, Date) {
        guard let period = gBizPeriod else { return (Date(), Date()) }
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
    
    private func makeContent() -> CalendarViewContent {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let currentDay = Calendar.current.component(.day, from: currentDate)
        let (_, end) = getStartEndDate()
        let ED = timestampHelper.DateWithHyphen(date: end).split(separator: "-")
        
        print("Checking End Date", end.iso8601withFractionalSeconds)
        print("Checking ED Date", timestampHelper.DateWithHyphen(date: end))
        var startDayRange = 0
        let endDay = Int(ED[0])
        let endMonth = Int(ED[1])
        let endYear = Int(ED[2])
        let startDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: currentDay))!
        let endDate = calendar.date(from: DateComponents(year: endYear, month: endMonth, day: endDay))!
        if isFirstLoad {
            previousSelectDay = self.selectedDay
        }
        let selectedDay = self.selectedDay
        loadFriendlyLabel()
        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions()))
            .withInterMonthSpacing(25)
            .withVerticalDayMargin(10)
            .withHorizontalDayMargin(10)
            .withDayItemModelProvider{
                day in
                var invariantViewProperties = DayLabel.InvariantViewProperties(
                    font: UIFont.systemFont(ofSize: 18),
                    textColor: UIColor.randevoo.mainBlack,
                    backgroundColor: .clear)
                if day.day < currentDay && day.month.month <= currentMonth && day.month.year <= currentYear || day.day > endDay! && day.month.month >= endMonth! && day.month.year >= endYear! {
                    invariantViewProperties.textColor = .lightGray
                    invariantViewProperties.backgroundColor = .white
                } else if self.unAvailableHour.count != 0 && self.unAvailableHour.contains(self.setDate(day: day)) {
                    invariantViewProperties.textColor = .lightGray
                    invariantViewProperties.backgroundColor = .white
                } else  if self.isFirstLoad {
                    if !self.unAvailableHour.contains(self.setDate(day: day)) {
                        let displayMonth = String(format: "%02d", day.month.month)
                        let displayDay = String(format: "%02d", day.day)
                        self.selectDate = String(day.month.year) + "-" + displayMonth + "-" + displayDay
                        if self.currentBizPeriod != nil {
                            self.createAvailableTime(timeslot: self.currentBizPeriod, day: self.setDate(day: day), date: self.selectDate, dayCalendar: day)
                        }
                        var isFound = false
                        for currentAvailable in self.availableTime {
                            if currentAvailable.bizAvailability! > 0 {
                                isFound = true
                                self.isFirstLoad = false
                                startDayRange += 1
                            }
                        }
                        if isFound {
                            invariantViewProperties.textColor = .white
                            invariantViewProperties.backgroundColor = UIColor.randevoo.mainBlack
                            self.updateSelectDate(date: self.selectDate.fetchDateISO!)
                            self.previousSelectDay = day
                            self.selectedDay = day
                            self.timeslotCollectionView.reloadData()
                        }
                    }
                } else if day == selectedDay {
                    if !self.unAvailableHour.contains(self.setDate(day: day)) {
                        invariantViewProperties.textColor = .white
                        invariantViewProperties.backgroundColor = UIColor.randevoo.mainBlack
                        self.timeslotCollectionView.reloadData()
                        let displayMonth = String(format: "%02d", day.month.month)
                        let displayDay = String(format: "%02d", day.day)
                        self.selectDate = String(day.month.year) + "-" + displayMonth + "-" + displayDay
                        if self.currentBizPeriod != nil {
                            self.createAvailableTime(timeslot: self.currentBizPeriod, day: self.setDate(day: day), date: self.selectDate, dayCalendar: day)
                            self.updateSelectDate(date: self.selectDate.fetchDateISO!)
                        }
                    } else {
                        invariantViewProperties.textColor = .lightGray
                        invariantViewProperties.backgroundColor = .white
                    }
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
