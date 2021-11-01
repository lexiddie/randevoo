//
//  AddImageCollectionCell.swift
//  randevoo
//
//  Created by Xell on 4/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit
import YPImagePicker
import AVKit

class AddImageCollectionCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AddImageCollectionCellDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, RemoveImageDelegate {
  
    var  size = 0
    let imageCollectionCell = "ImageCollectionCell"
    let addImageFooterID = "addImageFooterCell"
    var viewController: UIViewController!
    var imagePicker = UIImagePickerController()
    var productPhotos: [UIImage] = []
    private var config = YPImagePickerConfiguration()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.randevoo.mainLight
        setupUI()
        initiateCollectionView()
        imagePickerConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        backgroundColor = UIColor.randevoo.mainLight
        addSubview(imageCollectionView)
        imageCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.lessThanOrEqualTo(self).offset(10)
            make.right.equalTo(self).inset(10)
            make.bottom.equalTo(self).inset(10)
        }
    }
    
    lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.randevoo.mainLight
        collectionView.allowsSelection = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private func initiateCollectionView() {
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(AddImageFooterCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: addImageFooterID)
        imageCollectionView.register(AddImageCell.self, forCellWithReuseIdentifier: imageCollectionCell)
    }
    
    func addNewImage() {
        config.library.maxNumberOfItems = 10 - productPhotos.count
        if productPhotos.count < 10 {
            let picker = YPImagePicker(configuration: self.config)
            picker.didFinishPicking { [self, unowned picker] items, cancelled in
                if cancelled {
                    print("Picker was canceled")
                }
                for item in items {
                    switch item {
                    case .photo(let photo):
                        print(photo)
                        self.productPhotos.append(photo.image)
                        self.imageCollectionView.reloadData()
                    case .video(let video):
                        print(video)
                    }
                }
                sendProductImgToRootView()
                //                self.handleDisplaySlideShow(isUpdated: !cancelled)
                picker.dismiss(animated: true, completion: nil)
            }
            self.viewController.present(picker, animated: true, completion: nil)
        }

    }
    
    func sendProductImgToRootView(){
        let controller = viewController as! ListingController
        controller.getProductImg(imageView: productPhotos)
    }
    
    @objc func deleteImage(sender:UIButton) {
        let i = sender.tag
        productPhotos.remove(at: i)
        imageCollectionView.reloadData()
    }
    
    func setProductPhoto() {
        let controller = viewController as! ListingController
        controller.productImage = productPhotos
    }
    
    func removeImageCell(imageCell: AddImageCell) {
        let indexPath = imageCollectionView.indexPath(for: imageCell)
        productPhotos.remove(at: indexPath!.row)
        setProductPhoto()
        imageCollectionView.reloadData()
    }
    
}

extension AddImageCollectionCell {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: addImageFooterID, for: indexPath) as! AddImageFooterCell
        if productPhotos.count == 10 {
            footer.addButton.isHidden = true
        } else {
            footer.addButton.isHidden = false
        }
        footer.delegate = self
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCollectionCell, for: indexPath) as! AddImageCell
//        cell.removeButton.tag = indexPath.row
//        cell.removeButton.addTarget(self, action: #selector(deleteImage(sender:)), for: .touchUpInside)
        cell.productImageView.image = productPhotos[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    private func imagePickerConfig() {
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.usesFrontCamera = false
        config.showsPhotoFilters = false
        config.showsVideoTrimmer = false
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "randevoo"
//        config.albumName = "DefaultYPImagePickerAlbumName"
        config.startOnScreen = YPPickerScreen.library
//        config.screens = [.library]
        config.screens = [.library, .photo]
        config.showsCrop = .none
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = true
        config.hidesBottomBar = false
        config.preferredStatusBarStyle = UIStatusBarStyle.default
        config.maxCameraZoomFactor = 1.0
        
        config.library.options = nil
        config.library.onlySquare = false
        config.library.isSquareByDefault = true
        config.library.minWidthForItem = nil
        config.library.mediaType = .photo
        config.library.defaultMultipleSelection = true
        config.library.maxNumberOfItems = 10
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 3
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = true
        config.library.preselectedItems = nil
        
        config.video.compression = AVAssetExportPresetHighestQuality
        config.video.fileType = .mov
        config.video.recordingTimeLimit = 60.0
        config.video.libraryTimeLimit = 60.0
        config.video.minimumTimeLimit = 3.0
        config.video.trimmerMaxDuration = 60.0
        config.video.trimmerMinDuration = 3.0
    }
    
}

