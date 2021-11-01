//
//  BizProductSlideCell.swift
//  randevoo
//
//  Created by Lex on 16/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import ObjectMapper
import SwiftyJSON
import Alamofire
import AlamofireImage
import ImageSlideshow
import Cache
import SnapKit
import Hydra

class BizProductSlideCell: UICollectionViewCell {
    
    private var photosProvider = PhotosProvider()
    
    var width: NSLayoutConstraint?
    var height: NSLayoutConstraint?
    var isFloating = false
    var photoUrls: [String] = []
    
    var slidePhotos: [String]? {
        didSet {
            guard let slidePhotos = slidePhotos else { return }
            photoUrls = slidePhotos
            slideIndicator.numberOfPages = slidePhotos.count
            initialSlideShow()
        }
    }
    
    var isDisable: Bool! {
        didSet {
            if isDisable {
                statusView.isHidden = false
            } else {
                statusView.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        initialSlideShow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(productImageSlideShow)
        productImageSlideShow.translatesAutoresizingMaskIntoConstraints = false
        width = productImageSlideShow.widthAnchor.constraint(equalToConstant: self.frame.width)
        height = productImageSlideShow.heightAnchor.constraint(equalToConstant: self.frame.width)
        
        NSLayoutConstraint.activate([
            productImageSlideShow.centerXAnchor.constraint(equalTo: centerXAnchor),
            productImageSlideShow.centerYAnchor.constraint(equalTo: centerYAnchor),
            width!,
            height!
        ])
        
        productImageSlideShow.addSubview(statusView)
        statusView.snp.makeConstraints { (make) in
            make.edges.equalTo(productImageSlideShow)
        }
        statusView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.center.equalTo(statusView)
        }
    }
    
    func initialSlideShow() {
        productImageSlideShow.slideshowInterval = 5
        var imageUrls: [AlamofireSource] = []
        for url in photoUrls {
            imageUrls.append(AlamofireSource(url: URL(string: url)!))
        }
        if photoUrls.count != 0 {
            productImageSlideShow.setImageInputs(imageUrls)
        }
//        photosProvider.fetchImages(urlStrings: photoUrls).then { (sources) in
//            self.productImageSlideShow.setImageInputs(sources)
//        }
    }
    
    let slideIndicator: LabelPageIndicator = {
        let labelPageIndicator = LabelPageIndicator()
        labelPageIndicator.numberOfPages = 2
        return labelPageIndicator
    }()
    
    let productImageSlideShow: ImageSlideshow = {
        let imageSlideShow = ImageSlideshow()
        imageSlideShow.setImageInputs([ImageSource(image: UIImage(named: "DefaultPhoto")!.withRenderingMode(.alwaysOriginal))])
        imageSlideShow.layer.borderWidth = 0.3
        imageSlideShow.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        imageSlideShow.backgroundColor = UIColor.randevoo.mainLight
        imageSlideShow.clipsToBounds = true
        imageSlideShow.zoomEnabled = false
        imageSlideShow.contentScaleMode = .scaleAspectFill
        imageSlideShow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .right(padding: 10), vertical: .bottom)
        return imageSlideShow
    }()
    
    let statusView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    
    let statusLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.layer.backgroundColor = UIColor.randevoo.mainColor.withAlphaComponent(0.5).cgColor
        label.layer.cornerRadius = 5
        label.text = "Disabled"
        label.font = UIFont(name: "Quicksand-Bold", size: 35)
        label.textColor = UIColor.randevoo.mainColor
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.padding(0, 5, 0, 5)
        return label
    }()
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        guard let width = width, let height = height else {
            return
        }
        let normalized = y / 1.5
        let currentWidth = self.frame.width
        width.constant = currentWidth - normalized
        height.constant = self.frame.width - normalized
        let newNormalize = y / 250
        alpha = 1.0 - newNormalize
    }
}
