//
//  DebugHelper.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 02/04/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import Foundation
public class XcodeSchemeInfo {
    private init() {
    }

    public static let Debugging: Bool = {
        let dic = ProcessInfo().environment
        return dic["debug"] != nil
    }()
}
