//
//  MainView.swift
//  randevoo
//
//  Created by Lex on 18/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class MainView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.centerX.equalTo(self)
            make.height.equalTo(self.frame.width - 40 + 100)
            make.left.right.lessThanOrEqualTo(self)
        }
//        scrollView.snp.makeConstraints { (make) in
//            make.edges.equalTo(self)
//        }
        addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.bottom)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self)
        }
        addSubview(googleButton)
        googleButton.snp.makeConstraints{ (make) in
            make.top.equalTo(pageControl.snp.bottom).offset(50)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
        }
        addSubview(facebookButton)
        facebookButton.snp.makeConstraints{ (make) in
            make.top.equalTo(googleButton.snp.bottom).offset(20)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
        }
    }
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.addTarget(self, action: #selector(MainController.changePage(_:)), for: UIControl.Event.valueChanged)
        pageControl.backgroundColor = .clear
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.red
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.currentPageIndicatorTintColor = UIColor.randevoo.mainColor
        return pageControl
    }()
    
    let googleButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 45)
        button.setTitleColor(UIColor.randevoo.mainBlack, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 16)
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.setTitle("Continue with Google", for: .normal)
        button.setImage(UIImage(named: "GoogleLogo")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.randevoo.mainBlack.cgColor
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(MainController.handleGoogle(_:)), for: .touchUpInside)
        return button
    }()
    
    let facebookButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 45)
        button.setTitleColor(UIColor.randevoo.mainBlack, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 16)
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.setTitle("Continue with Facebook", for: .normal)
        button.setImage(UIImage(named: "FacebookLogo")!.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets.init(top: 10, left: 0, bottom: 10, right: 0)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.randevoo.mainBlack.cgColor
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(MainController.handleFacebook(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
}
