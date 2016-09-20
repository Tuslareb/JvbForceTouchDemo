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

    let maxScaleFactor:CGFloat = 0.3 //the maximum scale of the visual feedback effect
    let pressDurationBeforeFired = 0.5 //used when no force touch capability is available
    let forcePercentageBeforeFired: CGFloat = 0.9 //used when force touch capability is available
    
    //create the needed layers
    var feedbackLayer = CALayer()
    var orangeLayer = CALayer()
    
    //this highlights the view as long as it is pressed down
    var pressed: Bool = false {
        
        willSet{
            orangeLayer.backgroundColor = newValue ? UIColor.init(colorLiteralRed: 255/255, green: 107/255, blue: 40/255, alpha: 1).cgColor : UIColor.orange.cgColor
        }
    }
    
    
    var longPressRecognizer: UILongPressGestureRecognizer?
    var forceTouchRecognizer: ForceGestureRecognizer?
    var timer: Timer!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if #available(iOS 9, *){
            
            if traitCollection.forceTouchCapability == .available{
                print("force touch capability on this device")
                forceTouchRecognizer = ForceGestureRecognizer(target: self, action: #selector(forceTouchAction(gesture:)))
                forceTouchView.addGestureRecognizer(forceTouchRecognizer!)
            }
            else {
                print("no force touch capability on this device")
                longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gesture:)))
                longPressRecognizer!.minimumPressDuration = 0.0001
                forceTouchView.addGestureRecognizer(longPressRecognizer!)
            }
        }
        
        //give our layers rounded corners
        orangeLayer.cornerRadius = 20
        feedbackLayer.cornerRadius = 20
        
        //color our layers and make the feedbacklayer slightly transparant
        feedbackLayer.backgroundColor = UIColor.orange.cgColor
        orangeLayer.backgroundColor = UIColor.orange.cgColor
        feedbackLayer.opacity = 0.8

        //add a sublayer that acts as our 'normal' state layer and put the feebbacklayer behind this
        forceTouchView.layer.addSublayer(orangeLayer)
        forceTouchView.layer.insertSublayer(feedbackLayer, below: orangeLayer)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 9, *){
            
            //3D touch capability changed, so react to this change accordingly
            if traitCollection.forceTouchCapability != previousTraitCollection?.forceTouchCapability {

                //3D touch capability is now turned on
                if traitCollection.forceTouchCapability == .available{
                    
                    if let ftr = forceTouchRecognizer{
                        //the recognizer already existed but was disabled. Enable it.
                        ftr.isEnabled = true
                    }
                    else{
                        //the app apparently started without 3D touch enabled, so the 3D touch gestureRecognizer was never initialized. Do this now.
                        forceTouchRecognizer = ForceGestureRecognizer(target: self, action: #selector(forceTouchAction(gesture:)))
                        forceTouchView.addGestureRecognizer(forceTouchRecognizer!)
                    }
                    
                    //disable long press recognizer
                    if let lpr = longPressRecognizer { lpr.isEnabled = false }
                }
                
                //3D touch capability is now turned off.
                else{
                    
                    //the recognizer already existed but was disabled. Enable it
                    if let lpr = longPressRecognizer {
                        lpr.isEnabled = true
                    }
                    else{
                        //the app apparently started with 3D touch enabled, so the longPress gestureRecognizer was never initialized. Do this now.
                        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gesture:)))
                        longPressRecognizer!.minimumPressDuration = 0.0001
                        forceTouchView.addGestureRecognizer(longPressRecognizer!)
                    }
                    
                    //disable 3D touch recognizer
                    if let ftr = forceTouchRecognizer { ftr.isEnabled = false }
                }
            }
            
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        orangeLayer.frame = forceTouchView.bounds
        feedbackLayer.frame = forceTouchView.bounds
        
    }

    func longPressAction(gesture: UILongPressGestureRecognizer) {
        
        switch gesture.state{
        case .began:
            //start a timer when the user starts holding down on the view and call timerAction every 0.05 seconds
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerAction), userInfo: NSDate.timeIntervalSinceReferenceDate, repeats: true)
            pressed = true
        case .ended:
            //invalidate the timer when the user lifts off
            print("Long press ended")
            timer.invalidate()
            giveVisualFeedbackForPercentage(percentage: 0)
            pressed = false
        default: break 
        }
    }
    
    func forceTouchAction(gesture: ForceGestureRecognizer) {
        
        //a force of 1 counts as 'normal' pressure. We only want visual feedback when the pressure is more than normal.
        print("force applied: \(gesture.forceValue)")
        if gesture.forceValue > 1{
            
            pressed = true
            let percentage = gesture.forceValue / gesture.maxValue
            print("percentage is \(percentage)")
            giveVisualFeedbackForPercentage(percentage: percentage)

            if percentage > forcePercentageBeforeFired{
                
                //give taptic feedback. Caution: this is a private API!
                AudioServicesPlaySystemSound(1520)
                
                //reset the visual state to normal condition and disable the gesture recognizer
                gesture.isEnabled = false
                giveVisualFeedbackForPercentage(percentage: 0)
                pressed = false
                
                //enable the gesture again for the 'next' round
                gesture.isEnabled = true
                
            }
        }
        
        if gesture.state == .ended{
            
            //reset the visual state to normal condition in case user lifts finger before hitting the force target
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
                longPressRecognizer!.state = .ended
            }
        }
     
    }
    
    ///scales the feedbackLayer to a given percentage.
    private func giveVisualFeedbackForPercentage(percentage: CGFloat) {
        
        let scaleFactor = 1 + (percentage * maxScaleFactor)
        feedbackLayer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1)
        
    }

}

