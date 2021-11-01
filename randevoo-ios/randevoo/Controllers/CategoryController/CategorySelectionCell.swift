//
//  CategorytSelectionCell.swift
//  randevoo
//
//  Created by Lex on 21/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

protocol CategorytSelectionCellDelegate {
    func didSelectCategory(selectIndex: Int)
}

class CategorySelectionCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var delegate: CategorytSelectionCellDelegate?
    var categories: [Category] = []
    
    private let categoryCell = "categoryCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        initiateCollectionView()
        setupFocusBarView()
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
    
    private func initiateCollectionView() {
        selectionCollectionView.delegate = self
        selectionCollectionView.dataSource = self
        selectionCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: categoryCell)
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
    
    func animateBar(indexPath: Int) {
        let x = selectionCollectionView.frame.origin.x + 5
        let y = selectionCollectionView.frame.origin.y + 25
        let width = ((frame.width - 20) / 2)
//        let width = ((frame.width - 20) / 3)
        UIView.animate(withDuration: 0.5, animations: {
            self.focusBarView.frame = CGRect(x: x + (width * CGFloat(indexPath)), y: y + 10, width: width, height: 2)
        }, completion: nil)
    }
    
    private func setupFocusBarView() {
        selectionCollectionView.addSubview(focusBarView)
        let width = ((frame.width - 20) / 2)
//        let width = ((frame.width - 20) / 3)
        let x = selectionCollectionView.frame.origin.x + 5
        let y = selectionCollectionView.frame.origin.y + 25
        self.focusBarView.frame = CGRect(x: x, y: y + 10, width: width, height: 2)
    }
}

extension CategorySelectionCell {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (frame.width) / 2
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
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCell, for: indexPath) as! CategoryCell
        cell.category = categories[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        animateBar(indexPath: indexPath.item)
        delegate?.didSelectCategory(selectIndex: indexPath.item)
        selectionCollectionView.reloadData()
    }
}

