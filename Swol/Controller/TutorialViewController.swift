//
//  TutorialViewController.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 30/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

public class TutorialViewController: UIViewController {
    @IBAction func returnTap(_ sender: Any?) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func endTutorialTap(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
}
