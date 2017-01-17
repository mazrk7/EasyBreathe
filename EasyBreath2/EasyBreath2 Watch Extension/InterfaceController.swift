//
//  InterfaceController.swift
//  EasyBreath2 Watch Extension
//
//  Created by Charitos Charitou on 08/03/2016.
//  Copyright © 2016 Charitos Charitou. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity
import HealthKit


class InterfaceController: WKInterfaceController, WCSessionDelegate, HKWorkoutSessionDelegate {
    let session : WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    let motionManager = CMMotionManager()
    let healthStore = HKHealthStore()
    
    @IBOutlet private weak var valueLabel: WKInterfaceLabel!
    @IBOutlet private weak var stateButton : WKInterfaceButton!
    
    var timerArray = NSTimer()
    var timerSend = NSTimer()
    var dataArray: [String] = []
    var xString:String = ""
    var yString:String = ""
    var zString:String = ""
    var HRString:String = ""
    
    var active = false
    var workoutSession : HKWorkoutSession?
    
    let heartRateUnit = HKUnit(fromString: "count/min") // Definition of the unit
    var HKAnchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor)) // Search for new data
    
    override init() {
        super.init()
        
        session?.delegate = self
        session?.activateSession()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        motionManager.accelerometerUpdateInterval = 0.1
    }
    
    override func willActivate() {
        super.willActivate()
        
        if motionManager.accelerometerAvailable {
            let handler:CMAccelerometerHandler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                self.xString = String(format: "%.2f", data!.acceleration.x)
                self.yString = String(format: "%.2f", data!.acceleration.y)
                self.zString = String(format: "%.2f", data!.acceleration.z)
            }
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        }
        else {
            print("Not available")
        }
        
        guard HKHealthStore.isHealthDataAvailable() == true else {
            valueLabel.setText("not available")
            return
        }
        // Check whether HeathKit is available
        guard let quantityHRType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else {
            displayNotAllowed()
            return
        }
        // Returns heart rate as quantitity type
        
        let dataTypes = Set(arrayLiteral: quantityHRType)
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: dataTypes) { (success, error) -> Void in
            if success == false {
                self.displayNotAllowed()
            }
        }
        // Request authorization to record heart rates
    }
    
    func displayNotAllowed() {
        valueLabel.setText("not allowed")
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        switch toState {
        case .Running:
            workoutDidStart(date)
        case .Ended:
            workoutDidEnd(date)
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        // Do nothing for now
        NSLog("Workout error: \(error.userInfo)")
    }
    
    func startWorkout() {
        self.workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.CrossTraining, locationType: HKWorkoutSessionLocationType.Indoor)
        self.workoutSession?.delegate = self
        healthStore.startWorkoutSession(self.workoutSession!)
    }
    
    @IBAction func stateButtonTapped() {
        if (self.active) {
            //finish the current workout
            self.active = false
            self.stateButton.setTitle("Start")
            timerArray.invalidate()
            if let workout = self.workoutSession {
                healthStore.endWorkoutSession(workout)
            }
        } else {
            //start a new workout
            self.active = true
            self.stateButton.setTitle("Stop")
            timerArray = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "writeArray", userInfo: nil, repeats: true)
            timerSend = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "sendArray", userInfo: nil, repeats: true)
            startWorkout()
        }
    }
    
    func workoutDidStart(date : NSDate) {
        if let queryHR = createHeartRateStreamingQuery(date) {
            healthStore.executeQuery(queryHR)
        } else {
            valueLabel.setText("cannot start")
        }
    }
    
    func workoutDidEnd(date : NSDate) {
        if let queryHR = createHeartRateStreamingQuery(date) {
            healthStore.stopQuery(queryHR)
            valueLabel.setText("---")
        } else {
            valueLabel.setText("cannot stop")
        }
    }

    func createHeartRateStreamingQuery(workoutStartDate: NSDate) -> HKQuery? {
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { return nil }
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: HKAnchor, limit: Int(HKObjectQueryNoLimit)) {
            (query, sampleObjects, deletedObjects, newHKAnchor, error) -> Void in
            guard let newHKAnchor = newHKAnchor else {return}
            self.HKAnchor = newHKAnchor
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newHKAnchor, error) -> Void in
            self.HKAnchor = newHKAnchor!
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }

    func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        guard let sample = heartRateSamples.first else{return}
        let value = sample.quantity.doubleValueForUnit(self.heartRateUnit)
        let heartRateInt = UInt16(value)
        let heartRateString = String(heartRateInt)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.valueLabel.setText(heartRateString)
            self.HRString = heartRateString
        }
    }
    
    func writeArray() {
        self.dataArray.insert(NSDate().formattedISO8601, atIndex: 0)
        self.dataArray.insert(xString, atIndex: 1)
        self.dataArray.insert(yString, atIndex: 2)
        self.dataArray.insert(zString, atIndex: 3)
        self.dataArray.insert(HRString, atIndex: 4)
    }
    
    func sendArray() {
        if(WCSession.isSupported()) {
            let message = ["key":dataArray]
            // The paired iPhone has to be connected via Bluetooth.
            if let session = session where session.reachable {
                session.sendMessage(message,
                    replyHandler: { replyData in
                        // handle reply from iPhone app here
                        print(replyData)
                    }, errorHandler: { error in
                        // catch any errors here
                        print(error)
                })
            } else {
                print("Not connected")
            }
        }
    }
    
    override func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
        
        if let notificationIdentifier = identifier {
            if notificationIdentifier == "showBreatheAnimation" {
                presentControllerWithName("BreathingAnimation", context: nil)
                // pushControllerWithName("BreathingAnimation", context: nil)
                // return
            }
        }
    }
    
}

extension NSDate {
    struct Date {
        static let formatterISO8601: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            formatter.dateFormat = "HH:mm:ss.SSS' 'dd-MM-yyyy"
            return formatter
        }()
    }
    var formattedISO8601: String { return Date.formatterISO8601.stringFromDate(self) }
}