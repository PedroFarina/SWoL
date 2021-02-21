//
//  BackgroundButton.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 21/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

@IBDesignable internal class RoundButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            setNeedsDisplay()
        }
    }
}
