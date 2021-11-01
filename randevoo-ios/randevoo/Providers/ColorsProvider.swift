//
//  ColorsProvider.swift
//  randevoo
//
//  Created by Lex on 21/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Hydra
import ObjectMapper
import SwiftyJSON

class ColorsProvider {
    
    private let colors = Firestore.firestore()
    
    func getColors() -> [Color] {
        return Mapper<Color>().mapArray(JSONfile: "Colors.json")!
    }
    
    func getColorCode(name: String) -> String {
        let colors = Mapper<Color>().mapArray(JSONfile: "Colors.json")!
        if let color = colors.first(where: {$0.name == name}) {
            return color.code
        } else {
            return "FFFFFF"
        }
    }

}

