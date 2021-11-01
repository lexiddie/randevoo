//
//  BizReservedPageView.swift
//  randevoo
//
//  Created by Lex on 6/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

protocol BizReservedSelectionViewDelegate {
    func didSelectReseved(selectIndex: Int)
}

class BizReservedPageView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var delegate: BizReservedSelectionViewDelegate?
    var reservedPages: [ReservedPage] = []
    
    private var origins: [CGFloat] = []
    private let reservedFlexCell = "reservedFlexCell"
    
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
        addSubview(reservedCollectionView)
        reservedCollectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func initiateFocusBarView() {
        reservedCollectionView.addSubview(focusBarView)
        let x = reservedCollectionView.frame.origin.x
        let y = reservedCollectionView.frame.origin.y + 37
        self.focusBarView.frame = CGRect(x: x, y: y, width: 0, height: 2)
    }
    
    private func initiateCollectionView() {
        reservedCollectionView.delegate = self
        reservedCollectionView.dataSource = self
        reservedCollectionView.register(ReservedFlexCell.self, forCellWithReuseIdentifier: reservedFlexCell)
        reservedCollectionView.keyboardDismissMode = .interactive
    }
    
    lazy var reservedCollectionView: UICollectionView = {
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
        let y = reservedCollectionView.frame.origin.y + 37
        let label = UILabel()
        label.text = reservedPages[index].label
        let width = label.intrinsicContentSize.width + 10
        UIView.animate(withDuration: duration, animations: {
            self.focusBarView.frame = CGRect(x: x, y: y, width: width, height: 2)
        }, completion: nil)
    }
}

extension BizReservedPageView {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = reservedPages[indexPath.item].label
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
        return reservedPages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        var myRect = myCell.frame
//        let originInRootView = self.myCollectionView.convertPoint(myRect.origin, toView: self.view)
//        if indexPath.item == 0 {
//            animateBar(index: indexPath.item)
//        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reservedFlexCell, for: indexPath) as! ReservedFlexCell
        cell.reservedPage = reservedPages[indexPath.item]
        origins.append(cell.frame.origin.x)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        animateBar(index: indexPath.item)
        delegate?.didSelectReseved(selectIndex: indexPath.item)
        reservedCollectionView.reloadData()
    }
}
