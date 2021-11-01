//
//  ImageViewerController.swift
//  randevoo
//
//  Created by Xell on 13/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit
import AlamofireImage

class ImageViewerController: UIViewController {
    
    var imageUrl: URL
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    init(with imageUrl: URL) {
        self.imageUrl = imageUrl
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        scrollView.delegate = self
        setupUI()
        setupImageContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
//        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setupNavItems() {
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(named: "DismissIcon")!.withRenderingMode(.alwaysOriginal), for: .normal)
        dismissButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentHorizontalAlignment = .center
        dismissButton.contentVerticalAlignment = .center
        dismissButton.contentMode = .scaleAspectFit
        dismissButton.backgroundColor = UIColor.clear
        dismissButton.layer.cornerRadius = 8
        dismissButton.addTarget(self, action: #selector(handleBack(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        dismissButton.snp.makeConstraints{ (make) in
            make.height.width.equalTo(40)
        }
    }
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .changed:
                viewTranslation = sender.translation(in: view)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                })
            case .ended:
                if viewTranslation.y < 200 {
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.view.transform = .identity
                    })
                } else {
                    dismiss(animated: true, completion: nil)
                }
            default:
                break
        }
    }
    
    private func setupImageContent(){
        imageView.loadCacheImage(urlString: imageUrl.absoluteString)
    }
    
    private func setupUI(){
        view.backgroundColor = .clear
        navigationController?.title = "Photo"
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        blurEffectView.contentView.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .never
        let width = view.frame.width
        let height = view.frame.height - 50
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        scrollView.addSubview(blurEffectView)
        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.right.lessThanOrEqualTo(scrollView)
            make.center.equalTo(scrollView)
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
        scrollView.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.top.equalTo(view).inset(10)
            make.centerX.equalTo(view)
            make.height.equalTo(4)
            make.width.equalTo(40)
        }
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        scrollView.bounces = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainBlueGrey.withAlphaComponent(0.5)
        view.layer.cornerRadius = 2
        return view
    }()
    
}

extension ImageViewerController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
