//
//  InboxPageView.swift
//  randevoo
//
//  Created by Lex on 10/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

protocol InboxPageViewDelegate {
    func didSelectInbox(selectIndex: Int)
}

class InboxPageView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var delegate: InboxPageViewDelegate?
    var inboxPages: [InboxPage] = []
    
    private var origins: [CGFloat] = []
    private let inboxFlexCell = "inboxFlexCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        initiateCollectionView()
        initiateFocusBarView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        addSubview(inboxPageCollectionView)
        inboxPageCollectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func initiateFocusBarView() {
        inboxPageCollectionView.addSubview(focusBarView)
        let x = inboxPageCollectionView.frame.origin.x
        let y = inboxPageCollectionView.frame.origin.y + 37
        self.focusBarView.frame = CGRect(x: x, y: y, width: 0, height: 2)
    }
    
    private func initiateCollectionView() {
        inboxPageCollectionView.delegate = self
        inboxPageCollectionView.dataSource = self
        inboxPageCollectionView.register(InboxFlexCell.self, forCellWithReuseIdentifier: inboxFlexCell)
        inboxPageCollectionView.keyboardDismissMode = .interactive
    }
    
    lazy var inboxPageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    let focusBarView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.backgroundColor = UIColor.black
        return view
    }()
    
    func animateBar(index: Int, duration: Double = 0.5) {
        if origins.count == 0 {
            return
        }
        let x = origins[index]
        let y = inboxPageCollectionView.frame.origin.y + 37
        let label = UILabel()
        label.text = inboxPages[index].label
        let width = label.intrinsicContentSize.width + 10
        UIView.animate(withDuration: duration, animations: {
            self.focusBarView.frame = CGRect(x: x, y: y, width: width, height: 2)
        }, completion: nil)
    }
}

extension InboxPageView {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = inboxPages[indexPath.item].label
        let width = label.intrinsicContentSize.width + 10
        return CGSize(width: width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inboxPages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: inboxFlexCell, for: indexPath) as! InboxFlexCell
        cell.inboxPage = inboxPages[indexPath.item]
        origins.append(cell.frame.origin.x)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        animateBar(index: indexPath.item)
        delegate?.didSelectInbox(selectIndex: indexPath.item)
        inboxPageCollectionView.reloadData()
    }
}
