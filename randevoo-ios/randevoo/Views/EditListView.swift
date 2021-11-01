//
//  EditListView.swift
//  randevoo
//
//  Created by Xell on 4/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class EditListView: UIView {
    
    let alert = UIAlertController(title: nil, message: "Add to list...", preferredStyle: .alert)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(200)
            make.width.equalTo(frame.width)
            make.height.equalTo(90)
        }
        bottomView.addSubview(addToList)
        addToList.snp.makeConstraints { (make) in
            make.top.equalTo(bottomView).inset(10)
            make.centerX.equalTo(bottomView)
            make.left.right.lessThanOrEqualTo(bottomView).inset(20)
        }
        addSubview(mainCollectionView)
        mainCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(10)
            make.left.right.equalTo(self)
            make.centerX.equalTo(self)
            make.bottom.equalTo(bottomView.snp.top)
        }
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.top.equalTo(self).inset(10)
            make.centerX.equalTo(self)
            make.height.equalTo(4)
            make.width.equalTo(40)
        }
    }
    
    let bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    let mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    let addToList: UIButton = {
        let button = UIButton()
        button.setTitle("DONE", for: .normal)
        button.setTitleColor(UIColor.randevoo.mainLight, for: .normal)
        button.backgroundColor = UIColor.randevoo.mainColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "Quicksand-Bold", size: 20)
        button.contentEdgeInsets = UIEdgeInsets(top:7,left: 15,bottom: 7,right: 15)
        button.addTarget(self, action: #selector(EditListController.editListDone(_:)), for: .touchUpInside)
        return button
    }()
    
    
    let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainBlueGrey.withAlphaComponent(0.5)
        view.layer.cornerRadius = 2
        return view
    }()

    
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
//        self.present(alert, animated: true, completion: nil)
        
        //Timer to dissmiss the animation just for demo
        let date = Date().addingTimeInterval(1)
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(dissmissOverlay), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func dissmissOverlay(){
//        self.dismiss(animated: false, completion: nil)
    }
    
    
}
