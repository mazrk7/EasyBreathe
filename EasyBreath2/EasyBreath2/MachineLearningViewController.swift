//
//  MachineLearningViewController.swift
//  EasyBreath2
//
//  Created by Mark Zolotas on 01/03/2016.
//  Copyright © 2016 Charitos Charitou. All rights reserved.
//

import UIKit

var notification: UILocalNotification=UILocalNotification()

class MachineLearningViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var svmStatus: UILabel!
    @IBOutlet weak var dtStatus: UILabel!
    
    
    var theDate = NSDate()
    var dateComp:NSDateComponents = NSDateComponents()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func svmTraining(sender: AnyObject) {
        let accuracy = trainSVM()
        
        if accuracy >= 0.0 {
            svmStatus.text = "SVM Accuracy = " + String(accuracy) + "%!"
        }
        else {
            svmStatus.text = "SVM Not Trained!"
        }
    }
    
    @IBAction func dtTraining(sender: AnyObject) {
        let accuracy = trainDT()

        
        if accuracy >= 0.0 {
            dtStatus.text = "DT Accuracy = " + String(accuracy) + "%!"
        }
        else {
            dtStatus.text = "DT Not Trained!"
        }
    }
}
