//
//  WakeUpButton.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 25/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

internal class WakeUpButton: UIButton {
    internal var color: UIColor? = UIColor(named: "WakeButton")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor.systemBackground
        layer.masksToBounds = true
        layer.cornerRadius = frame.height/2
        titleEdgeInsets = .init(top: frame.height * 0.3, left: 0, bottom: 0, right: 0)
        imageEdgeInsets = .init(top: 0, left: 0, bottom: frame.height * 0.3, right: 0)
        setTitle("Wake Up".localized(), for: .normal)

        let image = UIImage(systemName: "power")?.withRenderingMode(.alwaysTemplate)
        let powerImageView =  UIImageView(image: image)
        powerImageView.tintColor = .white
        powerImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(powerImageView)
        NSLayoutConstraint.activate([
            powerImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            NSLayoutConstraint(item: powerImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.7, constant: 0),
            powerImageView.widthAnchor.constraint(equalTo: powerImageView.heightAnchor),
            powerImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.25)
        ])
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = frame.height/2
        titleEdgeInsets = .init(top: frame.height * 0.3, left: 0, bottom: 0, right: 0)
        imageEdgeInsets = .init(top: 0, left: 0, bottom: frame.height * 0.35, right: 0)


        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.height * 0.43
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)

        color?.setFill()
        path.fill()
    }
}
