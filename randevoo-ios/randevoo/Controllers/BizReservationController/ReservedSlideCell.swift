//
//  ReservedSlideCell.swift
//  randevoo
//
//  Created by Lex on 6/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import AlamofireImage
import ImageSlideshow

class ReservedSlideCell: UICollectionViewCell {
    
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
