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

    @IBOutlet var computer: UIImageView?
    public override func viewDidLoad() {
        _ = TutorialViewController.wakingImages
        _ = TutorialViewController.sleepingImages
    }

    public override func viewWillAppear(_ animated: Bool){
        computer?.image = TutorialViewController.sleepingImages[0]
        computer?.animationImages = TutorialViewController.sleepingImages
        computer?.animationDuration = 1.2
        computer?.animationRepeatCount = Int.max
        computer?.startAnimating()
    }

    @IBAction func continueTapWithAnimation(_ sender: Any) {
        self.computer?.stopAnimating()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.computer?.image = TutorialViewController.wakingImages[7]
            self.computer?.animationImages = TutorialViewController.wakingImages
            self.computer?.animationDuration = 0.8
            self.computer?.animationRepeatCount = 1
            self.computer?.startAnimating()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.performSegue(withIdentifier: "continue", sender: self)
        }
    }

    private static var sleepingImages: [UIImage] = {
        var images:[UIImage] = []

        for i in 0...8 {
            if let image = UIImage(named: "Sleeping0\(i)") {
                images.append(image)
            }
        }

        return images
    }()

    private static var wakingImages: [UIImage] = {
        var images: [UIImage] = []

        for i in 0...8 {
            if let image = UIImage(named: "WakingUp0\(i)") {
                images.append(image)
            }
        }

        return images
    }()
}
