//
//  LikePopUpController.swift
//  randevoo
//
//  Created by Xell on 2/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit

class LikePopUpController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var prevController = UIViewController()
    var shouldDismissInteractivelty: Bool?
    var listCategories:[Demo] = [Demo(name: "Shoe", imageView: "aj.jpg"),Demo(name: "Cloth", imageView: "pant.jpg")]
    let categoryCell = "AddToLikeCell"
    let prevView = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.randevoo.mainLight
        setupNavItems()
        setupUI()
        initialLikedCategoriesCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initialView() {
        let view = LikePopUpView(frame: self.view.frame)
        self.view = view
    }
    
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        return layout
    }()
    
    private func initialLikedCategoriesCollectionView() {
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        listCollectionView.register(AddToLikeCell.self, forCellWithReuseIdentifier: categoryCell)
        listCollectionView.collectionViewLayout = layout
    }
    
    //Setup View
    func setupUI() {
        view.addSubview(listCollectionView)
        listCollectionView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).inset(10)
            make.height.equalTo(80)
            make.centerY.equalTo(view)
        }
    }
    
    private func setupNavItems() {
        let titleLabel = UILabel()
        titleLabel.text = "ADD TO LIKE"
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
        
        let plusButton = UIBarButtonItem(image: UIImage(named: "AddingIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(viewAddNew(_:)))
        navigationItem.rightBarButtonItem = plusButton
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    }
    
    let listCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    //Action Button
    @objc func dissmissOverlay(){
        self.dismiss(animated: false, completion: nil)
    }
    
    //View add new which suppose to push navigation not present navigation
    @IBAction func viewAddNew (_ sender: UIButton) {
        let likeController = AddNewCategoryPopUpController()
        navigationController?.pushViewController(likeController, animated: true)
    }
    
    @objc func backgroundViewDidTap(){
        dismiss(animated: true, completion: {
                    self.prevController.dismiss(animated: true, completion: nil)})
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension LikePopUpController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 2
        return CGSize(width: width, height: width)
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
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCell, for: indexPath) as! AddToLikeCell
        let currentImage = UIImage(named: listCategories[indexPath.item].imageView)
        cell.titleImageView.image = currentImage
        cell.nameLabel.text = listCategories[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}




