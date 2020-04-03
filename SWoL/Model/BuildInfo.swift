//
//  DebugHelper.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 02/04/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Foundation
public class BuildInfo {
    private init() {
    }

    public static let isDev: Bool = {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }()
}
