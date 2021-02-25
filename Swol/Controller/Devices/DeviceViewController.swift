//
//  DeviceViewController.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 24/02/21.
//  Copyright © 2021 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import IntentsUI
import SwolIntents
import SwolBackEnd

internal class DeviceViewController: UIViewController, INUIAddVoiceShortcutButtonDelegate, INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {

    internal weak var device: DeviceProtocol? {
        didSet {
            nameLabel.text = device?.name
            macLabel.text = device?.mac
            internalIPBroadcastLabel.text = device?.address
            externalIPBroadcastLabel.text = device?.externalAddress
            externalIPLabel.text = "123.456.789.101"

            if let value = device {
                value.getIntent(completionHandler: { [weak self] (intent) in
                    self?.siriButton.shortcut = INShortcut(intent: intent)
                })
            } else {
                self.siriButton.isHidden = true
            }
        }
    }

    private let backView: DeviceBackgroundView = {
        let view = DeviceBackgroundView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true

        let image = UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate)
        button.setBackgroundImage(image, for: .normal)

        button.tintColor = UIColor(named: "Action")
        button.addTarget(self, action: #selector(shareTap), for: .touchUpInside)

        return button
    }()
    private lazy var editButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true

        let image = UIImage(systemName: "pencil")?.withRenderingMode(.alwaysTemplate)
        button.setBackgroundImage(image, for: .normal)

        button.tintColor = UIColor(named: "Action")
        button.addTarget(self, action: #selector(editTap), for: .touchUpInside)

        return button
    }()
    private let nameLabel: UILabel = .createStrongLabel(with: .largeTitle)

    private let macLabel: UILabel = .createStrongLabel(with: .title2)
    private let macDescLabel: UILabel = {
        let label = UILabel.createWeakLabel(with: .callout)
        label.text = "Mac Address".localized()

        return label
    }()

    private let internalIPBroadcastLabel: UILabel = .createStrongLabel(with: .title2)
    private let internalIPBroadcastDescLabel: UILabel = {
        let label = UILabel.createWeakLabel(with: .callout)
        label.text = "Internal Broadcast IP".localized()

        return label
    }()

    private let externalIPBroadcastLabel: UILabel = .createStrongLabel(with: .title2)
    private let externalIPBroadcastDescLabel: UILabel = {
        let label = UILabel.createWeakLabel(with: .callout)
        label.text = "External Broadcast IP".localized()

        return label
    }()

    private let externalIPLabel: UILabel = .createStrongLabel(with: .title2)
    private let externalIPDescLabel: UILabel = {
        let label = UILabel.createWeakLabel(with: .callout)
        label.text = "External IP Address".localized()

        return label
    }()

    private lazy var siriButton: INUIAddVoiceShortcutButton = {
        let button: INUIAddVoiceShortcutButton
        button = INUIAddVoiceShortcutButton(style: .black)
        button.backgroundColor = backView.backgroundColor
        button.delegate = self
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private lazy var wakeUpButton: WakeUpButton = {
        let button = WakeUpButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true

        button.addTarget(self, action: #selector(wakeUpTap), for: .touchUpInside)

        return button
    }()

    @objc func shareTap() {
        print("Share")
    }

    @objc func editTap() {
        print("Edit")
    }

    @objc func wakeUpTap() {
        print("Wake Up")
    }

    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        self.present(addVoiceShortcutViewController, animated: true)
    }

    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        self.present(editVoiceShortcutViewController, animated: true)
    }

    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        siriButton.shortcut = voiceShortcut?.shortcut
        controller.dismiss(animated: true, completion: nil)
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        device?.getIntent(completionHandler: { [weak self] (intent) in
            self?.siriButton.shortcut = INShortcut(intent: intent)
        })
        controller.dismiss(animated: true, completion: nil)
    }

    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        view.addSubview(backView)
        view.addSubview(shareButton)
        view.addSubview(editButton)
        view.addSubview(macLabel)
        view.addSubview(macDescLabel)
        view.addSubview(nameLabel)
        view.addSubview(internalIPBroadcastLabel)
        view.addSubview(internalIPBroadcastDescLabel)
        view.addSubview(externalIPBroadcastLabel)
        view.addSubview(externalIPBroadcastDescLabel)
        view.addSubview(externalIPLabel)
        view.addSubview(externalIPDescLabel)
        view.addSubview(wakeUpButton)
        view.addSubview(siriButton)
        activateConstraints()
    }

    private func activateConstraints() {
        var constraints: [NSLayoutConstraint] = [
            backView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            backView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            backView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),

            shareButton.topAnchor.constraint(equalTo: backView.topAnchor, constant: 20),
            shareButton.leftAnchor.constraint(equalTo: backView.leftAnchor, constant: 20),
            shareButton.heightAnchor.constraint(equalToConstant: 27),
            shareButton.widthAnchor.constraint(equalTo: shareButton.heightAnchor),

            editButton.topAnchor.constraint(equalTo: backView.topAnchor, constant: 20),
            editButton.rightAnchor.constraint(equalTo: backView.rightAnchor, constant: -20),
            editButton.heightAnchor.constraint(equalToConstant: 27),
            editButton.widthAnchor.constraint(equalTo: editButton.heightAnchor),

            wakeUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wakeUpButton.centerYAnchor.constraint(equalTo: backView.bottomAnchor),
            wakeUpButton.widthAnchor.constraint(equalTo: wakeUpButton.heightAnchor),
            wakeUpButton.heightAnchor.constraint(equalToConstant: 150)
        ]
        constraints.append(contentsOf: centralizedConstraints(of: nameLabel, relativeTo: editButton, constant: 20))
        constraints.append(contentsOf: centralizedConstraints(of: macLabel, relativeTo: nameLabel, constant: 15))
        constraints.append(contentsOf: centralizedConstraints(of: macDescLabel, relativeTo: macLabel))
        constraints.append(contentsOf: centralizedConstraints(of: internalIPBroadcastLabel, relativeTo: macDescLabel, constant: 10))
        constraints.append(contentsOf: centralizedConstraints(of: internalIPBroadcastDescLabel, relativeTo: internalIPBroadcastLabel))
        constraints.append(contentsOf: centralizedConstraints(of: externalIPBroadcastLabel, relativeTo: internalIPBroadcastDescLabel, constant: 10))
        constraints.append(contentsOf: centralizedConstraints(of: externalIPBroadcastDescLabel, relativeTo: externalIPBroadcastLabel))
        constraints.append(contentsOf: centralizedConstraints(of: externalIPLabel, relativeTo: externalIPBroadcastDescLabel, constant: 10))
        constraints.append(contentsOf: centralizedConstraints(of: externalIPDescLabel, relativeTo: externalIPLabel))
        constraints.append(contentsOf: centralizedConstraints(of: siriButton, relativeTo: externalIPDescLabel, constant: 30))

        NSLayoutConstraint.activate(constraints)
    }

    private func centralizedConstraints(of view: UIView, relativeTo topView: UIView, constant: CGFloat = 0) -> [NSLayoutConstraint] {
        return [
            view.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: constant),
            view.leftAnchor.constraint(equalTo: backView.leftAnchor, constant: 20),
            view.rightAnchor.constraint(equalTo: backView.rightAnchor, constant: -20)
        ]
    }
}
