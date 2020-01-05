//
//  TextTableViewCell.swift
//  SWoL
//
//  Created by Pedro Giuliano Farina on 04/01/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

@IBDesignable public class TextTableViewCell: UITableViewCell, UITextFieldDelegate {
    public static var xib: String = "TextTableViewCell"
    public static var identifier: String = "TextTableViewCell"
    public var completionCharacters: ((String?) -> Void)?
    public var changedCharacters: ((String?) -> Void)?

    @IBOutlet public weak var txtField: UITextField!
    @IBInspectable var maxCharacters: Int = -1
    public override func awakeFromNib() {
        self.isAccessibilityElement = true
        self.accessibilityNavigationStyle = .combined
        self.accessibilityLabel = txtField.accessibilityLabel
        self.accessibilityTraits = txtField.accessibilityTraits
        txtField.delegate = self
        txtField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        txtField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: .editingDidEnd)
    }

    @IBInspectable public var txtText: String? {
        get {
            return txtField.text
        }
        set {
            txtField.text = newValue
        }
    }

    public var txtPlaceholder: String? {
        get {
            return txtField.placeholder
        }
        set {
            txtField.placeholder = newValue
        }
    }

    @objc private func textFieldEditingDidEnd(_ textField: UITextField) {
        if maxCharacters != -1 && textField.text?.count !=  maxCharacters {
            textField.text = ""
        }
        completionCharacters?(textField.text)
    }

    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        guard let text = textField.text else {
            changedCharacters?(nil)
            return
        }
        changedCharacters?(text)
        if maxCharacters > 0 && text.count == maxCharacters {
            completionCharacters?(text)
        }
    }

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let maxLength = UInt32(exactly: maxCharacters as NSNumber) else {
            return true
        }

        guard let currentString: NSString = textField.text as NSString? else {
            return true
        }
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString

        if newString.length < maxLength {
            return true
        } else if newString.length == maxLength {
            return true
        }
        return false
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        completionCharacters?(textField.text)
        return true
    }
}

