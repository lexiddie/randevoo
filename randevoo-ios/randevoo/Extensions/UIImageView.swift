//
//  UIImageView.swift
//  randevoo
//
//  Created by Lex on 5/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import ImageSlideshow

extension UIImageView {
    
    func loadCacheImage(urlString: String) {
        if urlString != "" {
            if let imageData: UIImage = FCache.getImage(key: urlString), !FCache.isExpired(urlString) {
                self.image = imageData
            } else {
                let imageUrl = URL(string: urlString)
                self.af.setImage(withURL: imageUrl!, placeholderImage: UIImage(named: "DefaultPhoto")!.withRenderingMode(.alwaysOriginal), filter: nil, imageTransition: .crossDissolve(0.3)) { (response) in
                    guard let image = response.value else { return }
                    FCache.setImage(image: image, key: urlString, expiry: .seconds(60 * (60 * 24 * 7)))
                }
//                let urlRequest = URLRequest(url: URL(string: urlString)!)
//                gImageDownloader.download(urlRequest, completion:  { response in
//                    if case .success(let image) = response.result {
//                        FCache.setImage(image: image, key: urlString, expiry: .seconds(60 * (60 * 24 * 7)))
//                        self.image = image
//                    } else {
//                        let defaultImage = UIImage(named: "DefaultPhoto")!.withRenderingMode(.alwaysOriginal)
//                        self.image = defaultImage
//                    }
//                })
            }
        }
    }
    
    func loadCacheProfile(urlString: String) {
        if urlString != "" {
            if let imageData: UIImage = FCache.getImage(key: urlString), !FCache.isExpired(urlString) {
                self.image = imageData
            } else {
//                let imageUrl = URL(string: urlString)
//                self.af.setImage(withURL: imageUrl!, placeholderImage: UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal), filter: nil, imageTransition: .crossDissolve(0.3)) { (response) in
//                    guard let image = response.value else { return }
//                    FCache.setImage(image: image, key: urlString)
//                    // print("Added Profile \(String(urlString)) Into Cache")
//                }
                
                let urlRequest = URLRequest(url: URL(string: urlString)!)
                gImageDownloader.download(urlRequest, completion:  { response in
                    if case .success(let image) = response.result {
                        FCache.setImage(image: image, key: urlString)
                        self.image = image
                    } else {
                        let defaultImage = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
                        self.image = defaultImage
                    }
                })
            }
        }
    }
}

