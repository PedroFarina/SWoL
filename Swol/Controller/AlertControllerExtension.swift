//
//  AlertControllerExtension.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 26/12/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

extension UIAlertController {
    func addOkAction(handler: ((UIAlertAction) -> Void)? = nil) {
        let action = UIAlertAction(title: "Ok", style: .default, handler: handler)
        addAction(action)
    }
    func addCancelAction(handler: ((UIAlertAction) -> Void)? = nil) {
        let action = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: handler)
        addAction(action)
    }
}
