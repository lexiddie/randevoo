//
//  HandleAttribute.swift
//  randevoo
//
//  Created by Lex on 21/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit

class AttributeHelper {
    
    func getStringAttributed(mainString: String, secondString: String) -> NSMutableAttributedString {
        let att = NSMutableAttributedString(string: "\(mainString): \(secondString)");
        att.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.randevoo.mainBlack, range: NSRange(location: 0, length: att.string.split(separator: ":")[0].count))
        att.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSRange(location: att.string.split(separator: ":")[0].count, length: att.string.split(separator: ":")[1].count + 1))
        return att
    }
}

