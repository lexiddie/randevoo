//
//  UIImage.swift
//  randevoo
//
//  Created by Lex on 14/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import ImageSlideshow
import Hydra

extension UIImage {
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl: String) -> UIImage? {
        guard let bundleURL: URL = URL(string: gifUrl)
        else {
            print("image named \"\(gifUrl)\" doesn't exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    private func fetchImage(urlString: String) -> Promise<UIImage> {
        return Promise<UIImage>(in: .background) { (resolve, reject, _) in
            let imageUrl = URL(string: urlString)
            let current = UIImageView()
            let data = UIImage(named: "DefaultPhoto")!.withRenderingMode(.alwaysOriginal)
            current.af.setImage(withURL: imageUrl!, placeholderImage: data, filter: nil, imageTransition: .crossDissolve(0.3)) { (response) in
                guard let image = response.value else {
                    resolve(data)
                    return
                }
                FCache.setImage(image: image, key: urlString)
                resolve(image)
            }
        }
    }

}


