//
//  SwitchTableViewCell.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 27/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    static let xib: String = "SwitchTableViewCell"
    static let identifier: String = "SwitchTableViewCell"

    public lazy var onOff: UISwitch = {
        let onOff = UISwitch()
        onOff.addTarget(self, action: #selector(onOffOccur), for: .valueChanged)
        onOff.onTintColor = #colorLiteral(red: 0.2431372549, green: 0.4784313725, blue: 0.7607843137, alpha: 1)

        return onOff
    }()

    public var onOffChanged: ((UISwitch) -> Void)?

    override func awakeFromNib() {
        self.isAccessibilityElement = true
        self.accessibilityNavigationStyle = .combined
        self.accessibilityLabel = lblText
        self.accessoryView = onOff
    }

    public var isOn: Bool {
        get {
            return onOff.isOn
        }
        set {
            onOff.isOn = newValue
            onOffOccur()
        }
    }

    public var lblText: String? {
        get {
            return textLabel?.text
        }
        set {
            textLabel?.text = newValue
            self.accessibilityLabel = newValue
        }
    }
    @objc public func onOffOccur() {
        guard let onOffChanged = onOffChanged else {
            return
        }
        onOffChanged(onOff)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

