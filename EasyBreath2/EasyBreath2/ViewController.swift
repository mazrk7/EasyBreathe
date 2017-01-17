//
//  ViewController.swift
//  EasyBreath2
//
//  Created by Charitos Charitou on 09/02/2016.
//  Copyright © 2016 Charitos Charitou. All rights reserved.
//

import UIKit
import AVFoundation
import WatchConnectivity
import HealthKit
import CoreMotion
import MessageUI


var counter1 = 1
var counter2 = 1
var counter3 = 1
var counter4 = 1
var counter5 = 1
var counter6 = 1
var counter7 = 1

var counter = 0

var mailArray = [String]()

var another = String()  // initializer syntax

var result = false

var csvString: [Double] = []


class ViewController: UIViewController, WCSessionDelegate ,MFMailComposeViewControllerDelegate{
    let healthStore = HKHealthStore()
    var motionManager = CMMotionManager()
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var graphView: GraphView!

    var xString:String = ""
    var yString:String = ""
    var zString:String = ""
    
    @IBOutlet weak var value: UILabel!    
    let app = UIApplication.sharedApplication()
    
    
    func setupGraphDisplay() {

        var graphPoints:[Int] = [counter1, counter2, counter3, counter4, counter5, counter6, counter7]
    
    }
    
    let healthManager:HealthManager = HealthManager()
    let synth=AVSpeechSynthesizer()
    var myAudioPlayer = AVAudioPlayer()
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    var receivedArray: [String] = []
    var sampleArray: [String] = []
    var healthKitArray: [String] = []
    var motionArray: [String] = []
    var m = 0
    var n = 0
    var storedValue = 0
    var timerSlice = NSTimer()
    var timerHK = NSTimer()
    var timerMotion = NSTimer()
    var timerDuration = 60.00
    var globalCounter = 0
    
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var TuesdayLabel: UILabel!
    @IBOutlet weak var WednesdayLabel: UILabel!
    @IBOutlet weak var ThursdayLabel: UILabel!
    @IBOutlet weak var FridayLabel: UILabel!
    @IBOutlet weak var SaturdayLabel: UILabel!
    @IBOutlet weak var SundayLabel: UILabel!
    
    @IBAction func startButton(sender: AnyObject) {
        self.timerSlice = NSTimer.scheduledTimerWithTimeInterval(timerDuration, target: self, selector: "sliceArray", userInfo: nil, repeats: true)
        self.timerHK = NSTimer.scheduledTimerWithTimeInterval(timerDuration, target: self, selector: "queryHealthKit", userInfo: nil, repeats: true)
        self.timerMotion = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "sampleMotion", userInfo: nil, repeats: true)
        self.timerSlice = NSTimer.scheduledTimerWithTimeInterval(timerDuration, target: self, selector: "startML", userInfo: nil, repeats: true)
        
    }
    
    @IBOutlet weak var min_1: UILabel!
    @IBOutlet weak var min_2: UILabel!
    @IBOutlet weak var min_3: UILabel!
    @IBOutlet weak var min_4: UILabel!
    @IBOutlet weak var min_5: UILabel!
    @IBOutlet weak var min_6: UILabel!
    @IBOutlet weak var min_7: UILabel!
    
    @IBAction func sendEmailButtonTapped(sender: AnyObject) {
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
    }
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["charitos92@gmail.com"])
        mailComposerVC.setSubject("Sending Stress Intervals ")
        mailComposerVC.setMessageBody(another, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()

    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    @IBOutlet weak var MachineResult: UILabel!

    @IBAction func updateDate(sender: AnyObject) {
        
        if (counter1 >= 60) {
        mondayLabel.text = String(counter1-60) + " min"
        }
        else{
            mondayLabel.text = String(counter1) + " min"
        }
        
         if (counter2 >= 60) {
            TuesdayLabel.text = String(counter2-60) + " min"

        }
         else{
            TuesdayLabel.text = String(counter2) + " min"
            
        }
        if (counter3>=60){
            WednesdayLabel.text = String(counter3-60) + " min"
        }
        else{
            WednesdayLabel.text = String(counter3) + " min"
        }
        
        if (counter4>=60){
            ThursdayLabel.text = String(counter4-60) + " min"
        }
        else{
            ThursdayLabel.text = String(counter4) + " min"
        }
        
        if (counter5>=60){
            FridayLabel.text = String(counter5-60) + " min"
        }
        else{
            FridayLabel.text = String(counter5) + " min"
        }

        if (counter6>=60){
            SaturdayLabel.text = String(counter6-60) + " min"
        }
        else{
            SaturdayLabel.text = String(counter6) + " min"
        }
        
        if (counter7>=60){
            SundayLabel.text = String(counter7-60) + " min"
        }
        else{
            SundayLabel.text = String(counter7) + " min"
        }
    
        
        min_1.text = String((counter1/60))
        min_2.text = String(counter2/60)
        min_3.text = String(counter3/60)
        min_4.text = String(counter4/60)
        min_5.text = String(counter5/60)
        min_6.text = String(counter6/60)
        min_7.text = String(counter7/60)


        
    }
    
    @IBOutlet var MLResult: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        /* self.timerSlice = NSTimer.scheduledTimerWithTimeInterval(timerDuration, target: self, selector: "sliceArray", userInfo: nil, repeats: true)
        self.timerHK = NSTimer.scheduledTimerWithTimeInterval(timerDuration, target: self, selector: "queryHealthKit", userInfo: nil, repeats: true)
        self.timerMotion = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "sampleMotion", userInfo: nil, repeats: true)
        // self.timerSlice = NSTimer.scheduledTimerWithTimeInterval(timerDuration, target: self, selector: "startML", userInfo: nil, repeats: true) */
        
        if motionManager.accelerometerAvailable {
            let queue = NSOperationQueue.mainQueue()
            
            
            motionManager.startAccelerometerUpdatesToQueue(queue, withHandler:
                {data, error in
                    
                    guard let data = data else{
                        return
                    }
                    self.xString = String(format: "%.2f", data.acceleration.x)
                    self.yString = String(format: "%.2f", data.acceleration.y)
                    self.zString = String(format: "%.2f", data.acceleration.z)
                }
                
            )
        } else {
            print("Accelerometer is not available")
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureWCSession()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        configureWCSession()
    }
    
    private func configureWCSession() {
        session?.delegate = self;
        session?.activateSession()
    }
    
    func queryHealthKit() {
        super.viewDidLoad()
        let heartRateType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        let HRSamples = (Int(timerDuration) / 5)
        
        if (HKHealthStore.isHealthDataAvailable()){
            self.healthStore.requestAuthorizationToShareTypes(nil, readTypes:[heartRateType], completion:{(success, error) in
                let sortByTime = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending:false)
                let timeFormatter = NSDateFormatter()
                timeFormatter.dateFormat = "HH:mm:ss - dd/MM/YYYY"
                
                /* let dateFormatter = NSDateFormatter()
                 dateFormatter.dateFormat = "MM/dd/YYYY" */
                
                let query = HKSampleQuery(sampleType:heartRateType, predicate:nil, limit:HRSamples, sortDescriptors:[sortByTime], resultsHandler:{(query, results, error) in
                    guard let results = results else { return }
                    for quantitySample in results {
                        let quantity = (quantitySample as! HKQuantitySample).quantity
                        let heartRateUnit = HKUnit(fromString: "count/min")
                        self.healthKitArray.append(String(timeFormatter.stringFromDate(quantitySample.startDate)))
                        self.healthKitArray.append(String(quantity.doubleValueForUnit(heartRateUnit)))
                        /* self.healthKitArray.insert(String(quantity.doubleValueForUnit(heartRateUnit)), atIndex: 0)
                         self.healthKitArray.insert(String(timeFormatter.stringFromDate(quantitySample.startDate)), atIndex: 1) */
                    }
                    
                })
                self.healthStore.executeQuery(query)
            })
        }
        
        print(healthKitArray)
        
        // healthKitArray.removeAll()
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        self.receivedArray = message["key"]! as! Array
    }
    
    func sampleMotion() {
        self.motionArray.insert(NSDate().formattedISO8601, atIndex: 0)
        self.motionArray.insert(xString, atIndex: 1)
        self.motionArray.insert(yString, atIndex: 2)
        self.motionArray.insert(zString, atIndex: 3)
    }
    
    func sliceArray () {
        m = motionArray.count
        
        if n == 0 {
            n = m
        } else {
            n = m - storedValue
        }
        
        sampleArray = Array(motionArray[0..<n])
        storedValue = m
        
        print(sampleArray)
        
        /* if m > (8 * Int(timerDuration) + 4) {
            motionArray.removeAll()
            m = 0
            n = 0
            storedValue = 0
        } */
    }
    
    /* func sliceArray () {
        m = receivedArray.count
        
        if n == 0 {
            n = m
        } else {
            n = m - storedValue
        }
        
        sampleArray = Array(receivedArray[0..<n])
        storedValue = m
        
        dispatch_async(dispatch_get_main_queue()) {
            if let tableView = self.tableView {
                tableView.reloadData()
            }
        }
        
        // print(sampleArray)
    } */
    
    @IBOutlet weak var myVolumeController: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //mondayLabel.text = String(counter1)
        
        let myFilePathString = NSBundle.mainBundle().pathForResource("Mindfulness", ofType: "mp3")
        
        if let myFilePathString=myFilePathString{
            let myFilePathURL=NSURL(fileURLWithPath: myFilePathString)
            
            do{
             try   myAudioPlayer=AVAudioPlayer(contentsOfURL: myFilePathURL)
            }catch
            {
              print("error")
            }
        }
    }
    
    func startML() {
        
        if globalCounter >= 3 {
        
            let accWidth = 3
            let accHeight = sampleArray.count/5
            var rawAccIndex = 0
            var rawAccData = [Float](count: sampleArray.count - (sampleArray.count/5), repeatedValue: 0.0)
            
            let hrWidth = 1
            let hrHeight = healthKitArray.count/5
            var rawHRIndex = 0
            var rawHRData = [Float](count: healthKitArray.count - (healthKitArray.count/5), repeatedValue: 0.0)

            for (index, element) in sampleArray.enumerate() {
                if (index%4) != 0 {
                    if let value = Float(element) {
                        rawAccData[rawAccIndex] = value
                        rawAccIndex += 1
                    }
                }
            }
            
            for (index, element) in healthKitArray.enumerate() {
                if (index%1) != 0 {
                    if let value = Float(element) {
                        rawHRData[rawHRIndex] = value
                        rawHRIndex += 1
                    }
                }
            }
        
            let cvAccMat = initCvMatFromArray(rawAccData, Int32(accWidth), Int32(accHeight))
            let cvHRMat = initCvMatFromArray(rawHRData, Int32(hrWidth), Int32(hrHeight))

            let isStressed = classifyDTStress(cvAccMat, cvHRMat)
        
            result = isStressed
        
            if isStressed {
                let today = NSDate()
                let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                let components = calendar!.components([.Weekday], fromDate: today)
            
                if components.weekday == 2 {
                    counter1 = counter1 + 1
                }
            
                if components.weekday == 3 {
                    counter2 = counter2 + 1
                }
            
            
                if components.weekday == 4{
                    counter3 = counter3 + 1
                }
            
                if components.weekday == 5{
                    counter4 = counter4 + 1
                }
            
                if components.weekday == 6{
                    counter5 = counter5 + 1
                }
            
                if components.weekday == 7{
                    counter6 = counter6 + 1
                }
            
                if components.weekday == 1{
                    counter7 = counter7 + 1
                }
            
                let alertTime = NSDate().dateByAddingTimeInterval(10)
                let notifyAlarm = UILocalNotification()
                notifyAlarm.fireDate = alertTime
                notifyAlarm.timeZone = NSTimeZone.defaultTimeZone()
                notifyAlarm.soundName = UILocalNotificationDefaultSoundName
                notifyAlarm.category = "BreatheAlert"
                notifyAlarm.alertTitle = "Stress"
                notifyAlarm.alertBody = "You're stressed"
                app.scheduleLocalNotification(notifyAlarm)
            
                // let AlertView = UIAlertController(title: "You look stressed", message: "Please visit EasyBreath Meditation", preferredStyle: UIAlertControllerStyle.Alert)
            
                // AlertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
                //self.presentViewController(AlertView, animated: true, completion: nil)
            
                print("You are stressed")
                another += " 1"

            }
            else{
                print("You are not stressed")
                another += " 0"


            }
        }
        else {
            globalCounter = globalCounter + 1
        }
        
        healthKitArray.removeAll()
        
        if m > (8 * Int(timerDuration) + 4) {
            motionArray.removeAll()
            m = 0
            n = 0
            storedValue = 0
        }
    }
    
    @IBAction func updateR(sender: AnyObject) {
        
        if result {
            
            MachineResult.text = " You are stressed "
            
             MachineResult.font = UIFont.boldSystemFontOfSize(16.0)
        }
        else{
            
           MachineResult.text = " You are not stressed "
            MachineResult.font = UIFont.boldSystemFontOfSize(16.0)

        }

    }

    
    
    @IBAction func pause(sender: AnyObject) {
        myAudioPlayer.pause()
        counter2=counter2+1
    }

    @IBAction func play(sender: AnyObject) {
       myAudioPlayer.play()
        counter2=counter2+1


    }
    
    @IBAction func stop(sender: AnyObject) {
        myAudioPlayer.stop()
        myAudioPlayer.currentTime = 0
    }

    @IBAction func volume(sender: AnyObject) {
        myAudioPlayer.volume = myVolumeController.value
    }
    
    @IBAction func authorisation(sender: AnyObject) {
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                print("HealthKit authorization received.")
            }
            else
            {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension NSDate {
    struct Date {
        static let formatterISO8601: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            formatter.dateFormat = "HH:mm:ss - dd/MM/YYYY"
            return formatter
        }()
    }
    var formattedISO8601: String { return Date.formatterISO8601.stringFromDate(self) }
}
