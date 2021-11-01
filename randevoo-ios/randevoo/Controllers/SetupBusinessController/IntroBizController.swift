//
//  IntroBusinessController.swift
//  randevoo
//
//  Created by Lex on 23/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit
import ObjectMapper
import SwiftyJSON

class IntroBizController: UIViewController, UIScrollViewDelegate {
    
    var previousController: UIViewController!
    var personalAccount: PersonalAccount!
    
    private let accountsProvider = AccountsProvider()
    private let alertHelper = AlertHelper()
    private let totalPage: Int = 3
    private var pageControl: UIPageControl!
    private var scrollView: UIScrollView!
    private var frame: CGRect = CGRect()
    private var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        initialView()
        setupPageControlViews()
        fetchPersonalAccount()
    }
    
    private func initialView() {
        let view = IntroBizView(frame: self.view.frame)
        self.scrollView = view.scrollView
        self.pageControl = view.pageControl
        self.pageControl.numberOfPages = totalPage
        self.scrollView.delegate = self
        self.view = view
    }
    
    private func fetchPersonalAccount() {
        if let personalCache: PersonalAccount = FCache.get("personal"), !FCache.isExpired("personal") {
            let personalJson = Mapper().toJSONString(personalCache, prettyPrint: true)!
            self.personalAccount = personalCache
            print("Retrieved Cache Personal at IntroBiz: \(personalJson)")
        } else {
            print("Business Cache has been cleared at IntroBiz")
        }
    }
    
    private func generateView(viewIndex: Int, frame: CGRect) -> UIView {
        switch viewIndex {
        case 0:
            return IntroBizFirstView(frame: frame)
        case 1:
            return IntroBizSecondView(frame: frame)
        case 2:
            return IntroBizThirdView(frame: frame)
        default:
            return IntroBizFirstView(frame: frame)
        }
    }
    
    private func setupPageControlViews() {
        for index in 0..<totalPage {
            frame.origin.x = self.view.frame.width * CGFloat(index)
            frame.size = self.view.frame.size
            let subView = generateView(viewIndex: index, frame: frame)
            self.scrollView.addSubview(subView)
        }
        self.scrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(totalPage), height: self.frame.width - 40 + 100)
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(intervalPages(_:)), userInfo: nil, repeats: true)
    }
    
    @IBAction func intervalPages(_ sender: Any?) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        if pageNumber == 2 {
            pageControl.currentPage = 0
        } else {
            pageControl.currentPage = Int(pageNumber) + 1
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            let x = CGFloat(self.pageControl.currentPage) * self.scrollView.frame.size.width
            self.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }, completion: nil)
    }
    
    @IBAction func changePage(_ sender: Any?) {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    @IBAction func handleContinue(_ sender: Any?) {
        let controller = CreateBizNameController()
        controller.previousController = self.previousController
        self.navigationController?.pushViewController(controller, animated: true)
        
//        accountsProvider.findBusinessAccounts(userId: personalAccount.id).then { (businesses) in
//            if businesses.count < 2 {
//                let controller = CreateBizNameController()
//                controller.previousController = self.previousController
//                self.navigationController?.pushViewController(controller, animated: true)
//            } else {
//                self.alertHelper.showAlert(title: "Notice", alert: "Your business accounts have reached limit", controller: self)
//            }
//        }
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupNavItems() {
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(named: "DismissIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        dismissButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentHorizontalAlignment = .center
        dismissButton.contentVerticalAlignment = .center
        dismissButton.contentMode = .scaleAspectFit
        dismissButton.backgroundColor = UIColor.clear
        dismissButton.layer.cornerRadius = 8
        dismissButton.addTarget(self, action: #selector(handleDismiss(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        dismissButton.snp.makeConstraints{ (make) in
           make.height.width.equalTo(40)
        }
    }
    
}
