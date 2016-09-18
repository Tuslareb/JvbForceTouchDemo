//
//  ViewController.swift
//  JvbForceTouchDemo
//
//  Created by J.J.A.P. van Breukelen on 15-09-16.
//  Copyright © 2016 J.J.A.P. van Breukelen. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    
    @IBOutlet weak var forceTouchView: ForceTouchView!

    
    let maxScaleFactor:CGFloat = 0.3
    let pressDurationBeforeFired = 0.5
    var feedbackLayer = CALayer()
    var orangeLayer = CALayer()
    var pressed: Bool = false {
        
        willSet{
            orangeLayer.backgroundColor = newValue ? UIColor.init(colorLiteralRed: 255/255, green: 107/255, blue: 40/255, alpha: 1).cgColor : UIColor.orange.cgColor
        }
    }

    var longPressRecognizer: UILongPressGestureRecognizer!
    var timer: Timer!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gesture:)))
        longPressRecognizer.minimumPressDuration = 0.0001
        forceTouchView.addGestureRecognizer(longPressRecognizer)
        
        let forceTouchRecognizer = ForceGestureRecognizer(target: self, action: #selector(forceTouchAction(gesture:)))
        //forceTouchView.addGestureRecognizer(forceTouchRecognizer)
        
        orangeLayer.cornerRadius = 20
        feedbackLayer.cornerRadius = 20
        
        feedbackLayer.backgroundColor = UIColor.orange.cgColor
        orangeLayer.backgroundColor = UIColor.orange.cgColor
        feedbackLayer.opacity = 0.8

        forceTouchView.layer.addSublayer(orangeLayer)
        forceTouchView.layer.insertSublayer(feedbackLayer, below: orangeLayer)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        orangeLayer.frame = forceTouchView.bounds
        feedbackLayer.frame = forceTouchView.bounds
        
    }

    func longPressAction(gesture: UILongPressGestureRecognizer) {
        
        switch gesture.state{
        case .began:
            print("Long press received")
            //timer = Timer(timeInterval: 0.1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerAction), userInfo: NSDate.timeIntervalSinceReferenceDate, repeats: true)
        case .ended:
            print("Long press ended")
            timer.invalidate()
        default: break 
        }
    }
    
    func forceTouchAction(gesture: ForceGestureRecognizer) {
        
        print("force applied: \(gesture.forceValue)")
        if gesture.forceValue > 1{
            
            pressed = true
            let percentage = gesture.forceValue / gesture.maxValue
            print("percentage is \(percentage)")
            giveVisualFeedbackForPercentage(percentage: percentage)


            
            if percentage > 0.95{
                AudioServicesPlaySystemSound(1520)
                gesture.isEnabled = false
                //feedbackLayer.transform = CATransform3DMakeScale(1, 1, 1)
                giveVisualFeedbackForPercentage(percentage: 0)
                gesture.isEnabled = true
                pressed = false
            }
        }
        
        if gesture.state == .ended{
            giveVisualFeedbackForPercentage(percentage: 0)
            pressed = false

        }
    }
    
    func timerAction() {
        
        if let startTimeInterval = timer.userInfo as? TimeInterval{
            
            let now = NSDate.timeIntervalSinceReferenceDate
            let secondsPassed = now - startTimeInterval
            let percentage = (secondsPassed / pressDurationBeforeFired)
            print("secondspassed: \(secondsPassed)")
            giveVisualFeedbackForPercentage(percentage: CGFloat(percentage))
            
            if percentage > 1 {
                giveVisualFeedbackForPercentage(percentage: 0)
                longPressRecognizer.state = .ended
            }
        }
     
        //print("timer fired")
    }
    
    
    func giveVisualFeedbackForPercentage(percentage: CGFloat) {
        
        let scaleFactor = 1 + (percentage * maxScaleFactor)
        feedbackLayer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1)
        
    }

}

