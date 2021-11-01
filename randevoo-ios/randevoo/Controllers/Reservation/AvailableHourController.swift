//
//  AvailableHourView.swift
//  randevoo
//
//  Created by Xell on 17/11/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class AvailableHourController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let alert = UIAlertController(title: nil, message: "Add to list...", preferredStyle: .alert)
    let availableTimeCell = "AvailableTimeCell"
    var currentDate: String = ""
    var time: [TimeDemo] = []
    var lists: [DisplayList] = []
    var selectedTime = ""
    var availability : UIViewController!
    var businessId = ""
    var storeAccount: StoreAccount!
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.title = "Selection"
        setupTableView()
        setupUI()
        initialInfo()
        setAvailableConfirmButton(isActive: false)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AvailableTimeCell.self, forCellReuseIdentifier: availableTimeCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func setupUI() {
        let topWidth = (view.frame.width / 5) + 25
        let bottomWidth = view.frame.width / 6
        let rightMargin = view.frame.width / 4
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.lessThanOrEqualTo(view)
            make.height.equalTo(topWidth)
        }
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view)
            make.left.right.lessThanOrEqualTo(view)
            make.height.equalTo(bottomWidth)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(15)
            make.bottom.equalTo(bottomView.snp.top)
            make.left.right.lessThanOrEqualTo(view)
        }
        topView.addSubview(selectionLabel)
        selectionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topView).offset(10)
            make.height.equalTo(20)
            make.centerX.equalTo(view)
        }
        topView.addSubview(shopImg)
        shopImg.snp.makeConstraints { (make) in
            make.top.equalTo(selectionLabel.snp.bottom).offset(5)
            make.left.equalTo(view).offset(20)
            make.width.height.equalTo(40)
        }
        topView.addSubview(shopName)
        shopName.snp.makeConstraints { (make) in
            make.top.equalTo(shopImg).offset(5)
            make.left.equalTo(shopImg.snp.right).offset(20)
            make.right.equalTo(topView).inset(20)
            make.centerY.equalTo(shopImg)
        }
        topView.addSubview(date)
        date.snp.makeConstraints { (make) in
            make.top.equalTo(shopImg.snp.bottom).offset(10)
            make.left.equalTo(view).offset(20)
            make.bottom.equalTo(topView)
//            make.height.equalTo(16)
        }
        bottomView.addSubview(dateWithTime)
        dateWithTime.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).inset(rightMargin)
            make.centerY.equalTo(bottomView)
        }
        bottomView.addSubview(confirm)
        confirm.snp.makeConstraints { (make) in
            make.right.equalTo(view).inset(20)
            make.centerY.equalTo(bottomView)
        }
        
    }
    
    private func initialInfo(){
        date.text = currentDate
        dateWithTime.text = currentDate
        if storeAccount != nil {
            shopName.text = storeAccount.name
            shopImg.loadCacheImage(urlString: storeAccount.profileUrl)
        }
    }
    
    let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        table.allowsSelection = true
        return table
    }()
    
    let topView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let bottomView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainLight
        return view
    }()
    
    let selectionLabel : UILabel = {
        let label = UILabel()
        label.text = "Selection"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let shopImg : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "DisplayLogo")
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let shopName : UILabel = {
        let label = UILabel()
        label.text = "Nike"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let date : UILabel = {
        let label = UILabel()
        label.text = "Mon-10-2020"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let dateWithTime : UILabel = {
        let label = UILabel()
        label.text = "Mon-10-2020"
        label.textColor = UIColor.randevoo.mainBlack
        label.font = UIFont(name: "Quicksand-Bold", size: 15)
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    let confirm: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainLight, for: .normal)
        button.backgroundColor = UIColor.randevoo.mainColor
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 15)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top:15,left: 20,bottom: 15,right: 20)
        button.addTarget(self, action: #selector(AvailableHourController.pushToConfirm), for: .touchUpInside)
        return button
    }()
    
    private func setAvailableConfirmButton(isActive: Bool){
        if !isActive {
            confirm.backgroundColor = UIColor.randevoo.mainLightBlue
            confirm.isEnabled = false
        } else {
            confirm.backgroundColor = UIColor.randevoo.mainColor
            confirm.isEnabled = true
        }
    }
    
    @IBAction func pushToConfirm(){
        let nextVC = ConfirmReservationController()
        nextVC.reserveDate = currentDate
        nextVC.reseveTime = selectedTime
        nextVC.availability = availability
        nextVC.businessId = businessId
        nextVC.lists = lists
        nextVC.storeAccount = storeAccount
        navigationController!.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func overlay() {
        let imageView = UIImageView()
        imageView.loadGif(name: "cart")
        imageView.frame = CGRect(x: 220, y: 10, width: 40, height: 40)
        //        imageView.image = myImg
        alert.view.addSubview(imageView)
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
        
        //Timer to dissmiss the animation just for demo
        let date = Date().addingTimeInterval(1)
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(dissmissOverlay), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func dissmissOverlay(){
        self.dismiss(animated: false, completion: nil)
    }
    
}

extension AvailableHourController{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = view.frame.width/10
        return width
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return time.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: availableTimeCell, for: indexPath) as! AvailableTimeCell
        cell.timeLabel.text = time[indexPath.item].time
        if time[indexPath.item].time == selectedTime {
            cell.availableLabel.text = "Selected"
            cell.availableLabel.textColor = UIColor.randevoo.mainColor
            cell.timeLabel.textColor = UIColor.randevoo.mainColor
        } else if time[indexPath.item].bizAvailability! <= 0{
            cell.availableLabel.text = "Unavailable"
            cell.timeLabel.textColor = UIColor.randevoo.mainBlueGrey
            cell.availableLabel.textColor = UIColor.randevoo.mainBlueGrey
        } else if time[indexPath.item].status == "Available" {
            cell.availableLabel.text = "Available"
            cell.availableLabel.textColor = UIColor.black
            cell.timeLabel.textColor = UIColor.black
        } else if time[indexPath.item].status == "Exceed" {
            cell.availableLabel.text = "Exceed"
            cell.timeLabel.textColor = UIColor.randevoo.mainBlueGrey
            cell.availableLabel.textColor = UIColor.randevoo.mainBlueGrey
        } else if time[indexPath.item].status == "Occupied" {
            cell.availableLabel.text = "Occupied"
            cell.timeLabel.textColor = UIColor.randevoo.mainBlueGrey
            cell.availableLabel.textColor = UIColor.randevoo.mainBlueGrey
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if time[indexPath.item].bizAvailability! > 0 && time[indexPath.item].status == "Available" {
            selectedTime = time[indexPath.item].time
            print("Selected \(selectedTime)")
            print("Availability \(time[indexPath.item].bizAvailability)")
            dateWithTime.text = currentDate + " At: " + time[indexPath.item].time
            setAvailableConfirmButton(isActive: true)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

