//
//  DayLabel.swift
//  randevoo
//
//  Created by Alexander on 6/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import HorizonCalendar

class DayLabel: CalendarItemViewRepresentable {
    
    struct InvariantViewProperties: Hashable {
        let font: UIFont
        var textColor: UIColor
        var backgroundColor: UIColor
    }
    
    struct ViewModel: Equatable {
        let day: Day
    }
    
    static func makeView(withInvariantViewProperties invariantViewProperties: InvariantViewProperties) -> UILabel {
        let label = UILabel()
        let width = ((UIScreen.main.bounds.width - 40) / 14) - 5
        label.backgroundColor = invariantViewProperties.backgroundColor
        label.font = invariantViewProperties.font
        label.textColor = invariantViewProperties.textColor
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = width
        return label
    }
    
    static func setViewModel(_ viewModel: ViewModel, on view: UILabel) {
        view.text = "\(viewModel.day.day)"
    }

}
