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
    var feedbackLayer = CALayer()
    var orangeLayer = CALayer()
    var pressed: Bool = false {
        
        willSet{
            orangeLayer.backgroundColor = newValue ? UIColor.init(colorLiteralRed: 255/255, green: 107/255, blue: 40/255, alpha: 1).cgColor : UIColor.orange.cgColor
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gesture:)))
        longPressRecognizer.minimumPressDuration = 0.8
        //forceTouchView.addGestureRecognizer(longPressRecognizer)
        
        let forceTouchRecognizer = ForceGestureRecognizer(target: self, action: #selector(forceTouchAction(gesture:)))
        forceTouchView.addGestureRecognizer(forceTouchRecognizer)
        
        forceTouchView.layer.cornerRadius = 20
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
            
        case .ended:
            print("Long press ended")
        default: break 
        }
    }
    
    func forceTouchAction(gesture: ForceGestureRecognizer) {
        
        print("force applied: \(gesture.forceValue)")
        if gesture.forceValue > 1{
            
            pressed = true
            let scaleFactor = 1 + (((gesture.forceValue - 1) / gesture.maxValue) * maxScaleFactor)
            feedbackLayer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1)
            
            if gesture.forceValue > 6{
                AudioServicesPlaySystemSound(1520)
                gesture.isEnabled = false
                feedbackLayer.transform = CATransform3DMakeScale(1, 1, 1)
                gesture.isEnabled = true
                pressed = false
            }
        }else{
            feedbackLayer.transform = CATransform3DMakeScale(1, 1, 1)

        }
        
        if gesture.state == .ended{
            feedbackLayer.transform = CATransform3DMakeScale(1, 1, 1)
            pressed = false


        }
    }

}

