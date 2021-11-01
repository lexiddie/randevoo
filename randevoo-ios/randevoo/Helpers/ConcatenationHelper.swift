//
//  ProvideConcatenation.swift
//  randevoo
//
//  Created by Lex on 13/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit

class ConcatenationHelper {
    
    func getUsernameViaEmail(email: String) -> String {
        return String(email.split(separator: "@")[0].trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
    }
    
    func getUsernameViaName(name: String) -> String {
        return name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().removeWhitespace()
    }
}
