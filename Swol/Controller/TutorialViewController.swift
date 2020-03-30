//
//  TutorialViewController.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 30/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit

public class TutorialViewController: UIViewController {
    weak var previousTutorial: TutorialViewController?

    var isDone:Bool = false
    @IBAction func returnTap(_ sender: Any?) {
        dismiss(animated: false) {
            if self.isDone {
                self.previousTutorial?.isDone = true
                self.previousTutorial?.returnTap(nil)
            }
        }
    }

    @IBAction func endTutorialTap(_ sender: Any?) {
        isDone = true
        returnTap(sender)
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? TutorialViewController {
            self.previousTutorial = dest
        }
    }
}
