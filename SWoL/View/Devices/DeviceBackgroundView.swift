//
//  DeviceBackgroundView.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 24/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

internal class DeviceBackgroundView: UIView {
    internal var bottomColor: UIColor? = UIColor(named: "0") {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor(named: "Device Background")
        layer.masksToBounds = true
        layer.cornerRadius = 20
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        var rectCopySize = rect.size
        rectCopySize.height = 50
        let rectCopy = CGRect(origin: CGPoint(x: 0, y: rect.maxY - 50), size: rectCopySize)
        let path = UIBezierPath(rect: rectCopy)

        bottomColor?.setFill()
        path.fill()
    }

    internal func animateSuccess(_ success: Bool) {

    }
}
