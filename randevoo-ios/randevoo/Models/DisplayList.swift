//
//  DisplayList.swift
//  randevoo
//
//  Created by Xell on 17/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import Foundation

class DisplayList: Codable {
    
    var product: Product!
    var information: ListModel!
    
    init(product: Product, information: ListModel) {
        self.product = product
        self.information = information
    }
    
}
