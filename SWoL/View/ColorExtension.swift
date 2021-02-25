//
//  ColorExtension.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 24/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

extension UIColor {
    static let deviceColors: [UIColor?] = {
        return (0...7).map( { UIColor(named: "\($0)") } )
    }()
}

