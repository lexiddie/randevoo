//
//  UIFont.swift
//  randevoo
//
//  Created by Lex on 3/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import SnapKit

extension UIFont {
    
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                     attributes: [NSAttributedString.Key.font: self],
                                                     context: nil).size
    }
}
