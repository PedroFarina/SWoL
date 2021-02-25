//
//  LabelExtension.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 22/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

internal extension UILabel {
    static func createStrongLabel(with textStyle: UIFont.TextStyle) -> UILabel {
        createLabel(with: UIColor(named: "Strong Label"), and: .preferredFont(forTextStyle: textStyle))
    }

    static func createWeakLabel(with textStyle: UIFont.TextStyle) -> UILabel {
        createLabel(with: UIColor(named: "Weak Label"), and: .preferredFont(forTextStyle: textStyle))
    }

    static func createLabel(with color: UIColor?, and font: UIFont) -> UILabel {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false

        label.numberOfLines = 1
        label.textColor = color
        label.font = font
        label.textAlignment = .center
        return label
    }
}
