//
//  SearchSelectionView.swift
//  randevoo
//
//  Created by Lex on 27/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

protocol SearchSelectionViewDelegate {
    func didSelectSearch(selectIndex: Int)
}

class SearchSelectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var delegate: SearchSelectionViewDelegate?
    var searchSelections: [SearchSelection] = []
    
    private let selectionFlexCell = "selectionFlexCell"
    
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
        addSubview(selectionCollectionView)
        selectionCollectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    func initiateFocusBarView() {
        selectionCollectionView.addSubview(focusBarView)
        let x = selectionCollectionView.frame.origin.x + 1
        let y = selectionCollectionView.frame.origin.y + 35
        let width = (frame.width - 4) / 3
        self.focusBarView.frame = CGRect(x: x + width, y: y, width: width, height: 2)
    }
    
    private func initiateCollectionView() {
        selectionCollectionView.delegate = self
        selectionCollectionView.dataSource = self
        selectionCollectionView.register(SelectionFlexCell.self, forCellWithReuseIdentifier: selectionFlexCell)
        selectionCollectionView.keyboardDismissMode = .interactive
    }
    
    lazy var selectionCollectionView: UICollectionView = {
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
    
    func animateBar(indexPath: Int, duration: Double = 0.5) {
        let x = selectionCollectionView.frame.origin.x + 1
        let y = selectionCollectionView.frame.origin.y + 35
        let width = (frame.width - 4) / 3
        UIView.animate(withDuration: duration, animations: {
            self.focusBarView.frame = CGRect(x: x + (width * CGFloat(indexPath)), y: y, width: width, height: 2)
        }, completion: nil)
    }
}

extension SearchSelectionView {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (frame.width) / 3
        return CGSize(width: width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchSelections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: selectionFlexCell, for: indexPath) as! SelectionFlexCell
        cell.searchSelection = searchSelections[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        animateBar(indexPath: indexPath.item)
        delegate?.didSelectSearch(selectIndex: indexPath.item)
        selectionCollectionView.reloadData()
    }
}
