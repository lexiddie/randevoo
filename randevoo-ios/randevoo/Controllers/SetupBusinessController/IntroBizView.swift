//
//  IntroBizView.swift
//  randevoo
//
//  Created by Lex on 29/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

class IntroBizView: UIView {

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
            make.top.bottom.equalTo(self.safeAreaLayoutGuide)
            make.center.equalTo(self)
            make.left.right.lessThanOrEqualTo(self)
        }
        addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(60)
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self)
        }
        addSubview(continueButton)
        continueButton.snp.makeConstraints{ (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(40)
            make.left.right.lessThanOrEqualTo(self).inset(30)
            make.centerX.equalTo(self)
        }
    }
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        scrollView.backgroundColor = .clear
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.addTarget(self, action: #selector(IntroBizController.changePage(_:)), for: UIControl.Event.valueChanged)
        pageControl.backgroundColor = .clear
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.red
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.currentPageIndicatorTintColor = UIColor.randevoo.mainColor
        return pageControl
    }()
    
    let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 16)
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        button.setTitle("Continue", for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.randevoo.mainColor
        button.addTarget(self, action: #selector(IntroBizController.handleContinue(_:)), for: .touchUpInside)
        return button
    }()

}
