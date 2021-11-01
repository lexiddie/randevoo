//
//  AvailabilityController.swift
//  randevooo
//
//  Created by Xell on 16/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit
import HorizonCalendar
import FirebaseFirestore
import Presentr
import ObjectMapper
import Hydra

class TimeDemo: Codable {
    
    var time: String! = ""
    var status: String! = ""
    var bizAvailability: Int?
    
    init(time: String, status: String, bizAvailability: Int) {
        self.time = time
        self.status = status
        self.bizAvailability = bizAvailability
    }
}

class AvailabilityController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var storeAccount: StoreAccount!
    var storePeriod: BizPeriod!
    var products: [DisplayList] = []
    var storeTimeslots: [Timeslot] = []
    var customerTimeslots: [Timeslot] = []
    var isFirstLoad = false
    
    private var selectedDay: Day?
    private var previousSelectDay: Day?
    private let timestampHelper = TimestampHelper()

    private var topView: UIView!
    private var bottomView: UIView!
    private var selectButton: UIButton!
    private var usernameLabel: UILabel!
    private var locationLabel: UILabel!
    private var storeImageView: UIImageView!
    private var previousController : UIViewController!
    private let db = Firestore.firestore()
    
    private var selectDate = ""
    private var unavailableHours: [Int] = []
    private var availableTime: [TimeDemo] = []
    private var storeAvailability: Int = 0
    
    lazy var calendarView = CalendarView(initialContent: makeContent())
    
    let presenter: Presentr = {
        let width = ModalSize.full
        let height = ModalSize.fluid(percentage: 0.5)
        let center = ModalCenterPosition.bottomCenter
        let presentr = Presentr(presentationType: .custom(width: width, height: height, center: center))
        presentr.roundCorners = true
        presentr.cornerRadius = 15
        presentr.backgroundColor = UIColor.black
        presentr.backgroundOpacity = 0.7
        presentr.transitionType = .coverVertical
        presentr.dismissTransitionType = .coverVertical
        presentr.dismissOnSwipe = true
        presentr.dismissAnimated = true
        presentr.dismissOnSwipeDirection = .default
        return presentr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupNavItems()
        initialView()
        initialInfo()
        setupStoreAvailability()
        setupCalendar()
        retrieveDate()
        disableSelectButton(disable: true)
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "Availability"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "ArrowLeft")!.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentHorizontalAlignment = .center
        backButton.contentVerticalAlignment = .center
        backButton.contentMode = .scaleAspectFit
        backButton.backgroundColor = UIColor.white
        backButton.layer.cornerRadius = 8
        backButton.addTarget(self, action: #selector(handleBack(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.snp.makeConstraints{ (make) in
            make.height.width.equalTo(40)
        }
    }
    
    private func initialView() {
        let view = AvailabilityView(frame: self.view.frame)
        topView = view.topView
        bottomView = view.bottomView
        selectButton = view.selectButton
        usernameLabel = view.shopName
        locationLabel = view.shopLocation
        storeImageView = view.shopImg
        self.view = view
    }
    
    private func initialInfo() {
        usernameLabel.text = storeAccount.name
        locationLabel.text = storeAccount.location
        storeImageView.loadCacheImage(urlString: storeAccount.profileUrl)
    }
    
    private func setupCalendar() {
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.lessThanOrEqualTo(view).inset(20)
            make.centerX.equalTo(view)
            make.bottom.equalTo(bottomView.snp.top)
        }
    }
    
    private func setDate(day: Day) -> Int {
        let dateString = String(day.month.year) + "-" + String(day.month.month) + "-" + String(day.day)
        let weekday = Calendar.current.component(.weekday, from: dateString.fetchDateISO!)
        return weekday
    }
    
    private func retrieveDate() {
        guard let period = storePeriod else { return }
//        self.timeslot = storePeriod
        for time in period.bizHours {
            if !time.isActive {
                if time.dateLabel == "SUN" {
                    unavailableHours.append(1)
                } else if time.dateLabel == "MON" {
                    unavailableHours.append(2)
                } else if time.dateLabel == "TUE" {
                    unavailableHours.append(3)
                } else if time.dateLabel == "WED" {
                    unavailableHours.append(4)
                } else if time.dateLabel == "THU" {
                    unavailableHours.append(5)
                } else if time.dateLabel == "FRI" {
                    unavailableHours.append(6)
                } else {
                    unavailableHours.append(7)
                }
            }
        }
        let newContent = self.makeContent()
        calendarView.setContent(newContent)
        let now = Date()
        let currentYear = Calendar.current.component(.year, from: now)
        let currentMonth = Calendar.current.component(.month, from: now)
        let currentDay = Calendar.current.component(.day, from: now)
        let currentDate = Calendar.current.date(from: DateComponents(year: currentYear, month: currentMonth, day: currentDay))!
        calendarView.scroll(toDayContaining: currentDate, scrollPosition: .centered, animated: true)
    }
    
    
    private func setupStoreAvailability() {
        guard let period = storePeriod else { return}
        storeAvailability = Int(period.bizAvailability.value)
    }
    
    private func calculateStoreAvailability(dateString: String, timeString: String) -> Int {
        var availability = storeAvailability
        for time in storeTimeslots {
            if time.time == timeString && time.date == dateString && time.isApproved {
                availability -= 1
            }
        }
        return availability
    }
    
    private func checkIfOccupied(timeString: String, dateString: String) -> Bool {
        let filterUser = customerTimeslots.filter({$0.date == dateString})
        var isOccupied = false
        for filter in filterUser {
            let (userSt, userSm, userEt, userEm) = convertTimeToInt(timeString: filter.time)
            let (timeslotSt, timeslotSm, timeslotEt, timeslotEm) = convertTimeToInt(timeString: timeString)
            if  (userSt == timeslotSt && userSm == timeslotSm) || (userEt == timeslotEt && userEm == timeslotEm) || (userSt > timeslotSt && userSt < timeslotEt) || (userEt > timeslotSt && userEt < timeslotEt) || (userSt < timeslotSt && timeslotEt < userEt) || (userSt < timeslotSt && timeslotSt < userEt){
                isOccupied = true
                break
            } else {
                isOccupied = false
            }
        }
        return isOccupied
    }
    
    private func convertTimeToInt(timeString: String) -> (Int, Int, Int, Int) {
        let timeSplit = timeString.split(separator: "-")
        let startTime = timeSplit[0].split(separator: ":")
        let endTime = timeSplit[1].split(separator: ":")
        let startHour = Int(startTime[0].trimmingCharacters(in: .whitespaces))!
        let startMinute = Int(startTime[1].trimmingCharacters(in: .whitespaces))!
        let endHour = Int(endTime[0].trimmingCharacters(in: .whitespaces))!
        let endMinute = Int(endTime[1].trimmingCharacters(in: .whitespaces))!
        return (startHour, startMinute, endHour, endMinute)
    }
    
    private func createAvailableTimeForDisplay(timeString: String, date: String, startTime: Double, gap: Double, endTime: Double, dayCalendar: Day, currentMonth: Int, currentDay: Int, currentHour: Int, currentMinute: Int, bookedTimeString: [Timeslot] ) {
        let newBizAvailability = calculateStoreAvailability(dateString: date, timeString: timeString)
        var currentHour = Double(currentHour)
        if currentMinute > 30 {
            currentHour += 0.5
        } else {
            currentHour += 0
        }
        print(timeString)
        print(startTime)
        print(gap)
        print(endTime)
        if startTime + gap <= endTime {
            if dayCalendar.month.month == currentMonth && dayCalendar.day == currentDay && !checkIfOccupied(timeString: timeString, dateString: date){
                if Double(currentHour) + 1 < Double(startTime) && !bookedTimeString.contains(where: {$0.time == timeString}) {
                    availableTime.append(TimeDemo(time: timeString, status: "Available", bizAvailability: newBizAvailability ))
                } else {
                    availableTime.append(TimeDemo(time: timeString, status: "Exceed", bizAvailability: newBizAvailability))
                }
            } else if checkIfOccupied(timeString: timeString, dateString: date){
                availableTime.append(TimeDemo(time: timeString, status: "Occupied", bizAvailability: newBizAvailability))
            } else {
                availableTime.append(TimeDemo(time: timeString, status: "Available", bizAvailability: newBizAvailability))
            }
        }
    }
    
    private func createAvailableTime(timeslot: BizPeriod, day: Int, date: String, dayCalendar: Day) {
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
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
        } else{
            let found = timeslot.bizHours.filter({$0.dateLabel == "SAT"})
            currentTime = found[0]
        }
        let time = currentTime.openTime.split(separator: ":")
        var startHour = Double(time[0])!
        var startTime = setTimeToDouble(time: currentTime.openTime)
        let endTime = setTimeToDouble(time: currentTime.closeTime)
        var gap = Double(timeslot.bizTimeslot.value)
        var userContainBookedDate = false
        var bookedTimeString: [Timeslot] = []
        if customerTimeslots.contains(where: {$0.date == date}) {
            userContainBookedDate = true
            bookedTimeString = customerTimeslots.filter({$0.date == date})
        }
        var previousGap = 0.0
        while startTime <= endTime {
            if startTime.truncatingRemainder(dividingBy: startHour) == 0 && gap != 0.5 && previousGap != 0.5  {
                print(" 1 start time \(startTime)")
                let timeString = String(Int(startTime)) + ":00 - " + String(Int(startTime + gap)) + ":00"
                createAvailableTimeForDisplay(timeString: timeString, date: date, startTime: startTime, gap: gap, endTime: endTime, dayCalendar: dayCalendar, currentMonth: currentMonth, currentDay: currentDay, currentHour: currentHour, currentMinute: currentMinute, bookedTimeString: bookedTimeString)
                startTime += gap
                startHour += gap
            } else if startHour <= startTime && startTime <=  (startHour + 1.0) && gap != 0.5 && previousGap != 0.5  {
                print(" 2 start time \(startTime)")
                let timeString = String(Int(startTime)) + ":30 - " + String(Int(startTime + gap)) + ":30"
                createAvailableTimeForDisplay(timeString: timeString, date: date, startTime: startTime, gap: gap, endTime: endTime, dayCalendar: dayCalendar, currentMonth: currentMonth, currentDay: currentDay, currentHour: currentHour, currentMinute: currentMinute, bookedTimeString: bookedTimeString)
                startTime += gap
                startHour += gap
            } else if startTime.truncatingRemainder(dividingBy: startHour) == 0 && ( gap == 0.5 || previousGap == 0.5 ) {
                if gap == 0.5 {
                    print(" 5 start time \(startTime)")
                    let timeString = String(Int(startTime)) + ":00 - " + String(Int(startTime)) + ":30"
                    createAvailableTimeForDisplay(timeString: timeString, date: date, startTime: startTime, gap: gap, endTime: endTime, dayCalendar: dayCalendar, currentMonth: currentMonth, currentDay: currentDay, currentHour: currentHour, currentMinute: currentMinute, bookedTimeString: bookedTimeString)
                    previousGap = 0.5
                    gap = 1
                } else if  previousGap == 0.5 {
                    print(" 6 start time \(startTime)")
                    let timeString = String(Int(startTime)) + ":30 - " + String(Int(startTime + 1)) + ":00"
                    createAvailableTimeForDisplay(timeString: timeString, date: date, startTime: startTime + 0.5, gap: previousGap, endTime: endTime, dayCalendar: dayCalendar, currentMonth: currentMonth, currentDay: currentDay, currentHour: currentHour, currentMinute: currentMinute, bookedTimeString: bookedTimeString)
                    startTime += 1
                    startHour += 1
                    previousGap = 1
                    gap = 0.5
                }
                
            }
            else if startHour <= startTime && startTime <=  (startHour + 1.0) && (gap == 0.5 || previousGap == 0.5)  {
                if gap == 0.5 {
                    print(" 3 start time \(startTime)")
                    let timeString = String(Int(startTime)) + ":30 - " + String(Int(startTime + 1)) + ":00"
                    createAvailableTimeForDisplay(timeString: timeString, date: date, startTime: startTime, gap: gap, endTime: endTime, dayCalendar: dayCalendar, currentMonth: currentMonth, currentDay: currentDay, currentHour: currentHour, currentMinute: currentMinute, bookedTimeString: bookedTimeString)
                    startTime += gap
                    startHour += gap
                    previousGap = 0.5
                    gap = 1.0
                } else if  previousGap == 0.5 {
                    print(" 4 start time \(startTime)")
                    let timeString = String(Int(startTime)) + ":00 - " + String(Int(startTime)) + ":30"
                    createAvailableTimeForDisplay(timeString: timeString, date: date, startTime: startTime, gap: previousGap, endTime: endTime, dayCalendar: dayCalendar, currentMonth: currentMonth, currentDay: currentDay, currentHour: currentHour, currentMinute: currentMinute, bookedTimeString: bookedTimeString)
                    startTime += previousGap
                    startHour += previousGap
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
    
    func popNavigation(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showMap(_ sender: Any){
        let controller = StoreMapController()
        controller.storeAccount = storeAccount
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func showAvailableHour(_ sender: Any) {
        let controller = AvailableHourController()
        controller.availability = self
        controller.time = availableTime
        controller.currentDate = selectDate
        controller.businessId = storePeriod.businessId
        controller.lists = products
        controller.storeAccount = storeAccount
        let navController = UINavigationController(rootViewController: controller)
        customPresentViewController(presenter, viewController: navController, animated: true, completion: nil)
    }
    
    func disableSelectButton(disable: Bool){
        if disable {
            selectButton.backgroundColor = UIColor.randevoo.mainLightBlue
            selectButton.isEnabled  = false
        } else {
            selectButton.backgroundColor = UIColor.randevoo.mainColor
            selectButton.isEnabled  = true
        }
    }
}

extension AvailabilityController {
    
    private func getStartEndDate() -> (Date, Date) {
        guard let period = storePeriod else { return (Date(), Date()) }
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
                    textColor: .black,
                    backgroundColor: .clear)
                if day.day < currentDay && day.month.month <= currentMonth && day.month.year <= currentYear || day.day > endDay! && day.month.month >= endMonth! && day.month.year >= endYear! {
                    invariantViewProperties.textColor = .lightGray
                    invariantViewProperties.backgroundColor = .white
                    if day == selectedDay {
                        self.disableSelectButton(disable: true)
                    }
                }else if self.unavailableHours.count != 0 && self.unavailableHours.contains(self.setDate(day: day)) {
                    invariantViewProperties.textColor = .lightGray
                    invariantViewProperties.backgroundColor = .white
                    if day == selectedDay {
                        self.disableSelectButton(disable: true)
                    }
                } else  if self.isFirstLoad {
                    if !self.unavailableHours.contains(self.setDate(day: day)) {
                        let displayMonth = String(format: "%02d", day.month.month)
                        let displayDay = String(format: "%02d", day.day)
                        self.selectDate = String(day.month.year) + "-" + displayMonth + "-" + displayDay
                        if self.storePeriod != nil {
                            self.createAvailableTime(timeslot: self.storePeriod, day: self.setDate(day: day), date: self.selectDate, dayCalendar: day)
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
                            invariantViewProperties.backgroundColor = .black
                            self.previousSelectDay = day
                            self.selectedDay = day
                            self.disableSelectButton(disable: false)
                        }
                    }
                } else if day == selectedDay {
                    if !self.unavailableHours.contains(self.setDate(day: day)) {
                        invariantViewProperties.textColor = .white
                        invariantViewProperties.backgroundColor = .black
                        self.disableSelectButton(disable: false)
                        let displayMonth = String(format: "%02d", day.month.month)
                        let displayDay = String(format: "%02d", day.day)
                        self.selectDate = String(day.month.year) + "-" + displayMonth + "-" + displayDay
                        if self.storePeriod != nil {
                            self.createAvailableTime(timeslot: self.storePeriod, day: self.setDate(day: day), date: self.selectDate, dayCalendar: day)
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

