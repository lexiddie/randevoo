//
//  QrCodeGenerator.swift
//  randevoo
//
//  Created by Xell on 16/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import Foundation

class QrCodeGenerator {
    
    func qrCode() -> String {
        let genString = NSUUID().uuidString.split(separator: "-")
        let result = "\(genString[0])-\(genString[1])"
        print("genString", result)
        return result
    }
}
