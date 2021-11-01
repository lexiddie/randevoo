//
//  PhotosProvider.swift
//  randevoo
//
//  Created by Lex on 30/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import AlamofireImage
import ImageSlideshow
import Hydra

class PhotosProvider {
    
//    let downloader = ImageDownloader()
    
    func fetchImages(urlStrings: [String]) -> Promise<[ImageSource]> {
        return Promise<[ImageSource]>(in: .background) { (resolve, reject, _) in
            var imageSources: [ImageSource] = []
            for i in urlStrings {
                self.fetchImage(urlString: i).then { (source) in
                    imageSources.append(source)
                    
                    if urlStrings.count == imageSources.count {
                        resolve(imageSources)
                    }
                }
            }
        }
    }
    
    
    private func fetchImage(urlString: String) -> Promise<ImageSource> {
        return Promise<ImageSource>(in: .background) { (resolve, reject, _) in
            if let imageData: UIImage = FCache.getImage(key: urlString), !FCache.isExpired(urlString) {
                let record = ImageSource(image: imageData)
                resolve(record)
            } else {
                let urlRequest = URLRequest(url: URL(string: urlString)!)
                gImageDownloader.download(urlRequest, completion:  { response in
                    if case .success(let image) = response.result {
                        FCache.setImage(image: image, key: urlString, expiry: .seconds(60 * (60 * 24 * 7)))
                        let record = ImageSource(image: image)
                        resolve(record)
                    } else {
                        let defaultImage = UIImage(named: "DefaultPhoto")!.withRenderingMode(.alwaysOriginal)
                        let record = ImageSource(image: defaultImage)
                        resolve(record)
                    }
                })
            }
        }
    }
    
}
