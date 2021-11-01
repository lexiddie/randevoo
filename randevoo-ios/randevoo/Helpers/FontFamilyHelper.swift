//
//  FontFamilyHelper.swift
//  randevoo
//
//  Created by Lex on 18/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit

class FontFamilyHelper {
    
    //SegoeUI
    //SegoeUI-Bold
    //FiraSans-Regular
    //FiraSans-Bold
    //FiraSans-Medium
    //BlairITCTTBold
    func printFonts() {
        for familyName in UIFont.familyNames {
            print("\n-- \(familyName) \n")
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print(fontName)
            }
        }
    }
}
