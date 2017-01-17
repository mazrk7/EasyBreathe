//
//  BreatheAnimationInterfaceController.swift
//  EasyBreath2
//
//  Created by Pascal Loose on 13/03/2016.
//  Copyright © 2016 Charitos Charitou. All rights reserved.
//

import WatchKit
import Foundation


class BreatheAnimationInterfaceController: WKInterfaceController {
    @IBOutlet var breatheCircle: WKInterfaceImage!
    @IBOutlet private weak var instructLabel: WKInterfaceLabel!
    
    var timer = NSTimer()
    var secondTimer = NSTimer()
    
    var animationState = true
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        breatheCircle.setImageNamed("Steps")
        
        breatheCircle.startAnimatingWithImagesInRange(NSRange(location: 0, length: 132), duration: 4, repeatCount: 1)
        
        instructLabel.setText("Breathe in")
        
        timer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "updateInstruction1", userInfo: nil, repeats: false)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: "updateInstruction2", userInfo: nil, repeats: false)
        
        // timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "updateInstruction3", userInfo: nil, repeats: false)
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        timer.invalidate()
    }
    
    func updateInstruction1() {
        instructLabel.setText("Hold your breath")
        
        breatheCircle.stopAnimating()
    }
    
    func updateInstruction2() {
        instructLabel.setText("Breathe out")
        
        breatheCircle.startAnimatingWithImagesInRange(NSRange(location: 0, length: 132), duration: 4, repeatCount: 1)
    }
    
    /* func updateInstruction3() {
        timer.invalidate()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "updateInstruction1", userInfo: nil, repeats: false)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: "updateInstruction2", userInfo: nil, repeats: false)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "updateInstruction3", userInfo: nil, repeats: false)
    } */
}
