//
//  Mappable.swift
//  randevoo
//
//  Created by Alexander on 11/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON
import CryptoSwift

extension BaseMappable {
    
//    < is sorting ascending,
//    > is sorting descending
    
    func hashDataObject() -> String {
        var result = Mapper().toJSONString(self, prettyPrint: true)!
        result = String(result.sorted(by: > ))
        return result.sha256()
    }
    
    private func hashDataObject<T: BaseMappable>(data: T) -> String {
        var result = Mapper().toJSONString(data, prettyPrint: true)!
        result = String(result.sorted(by: > ))
        return result.sha256()
    }
    
}
