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
    
    let maxScaleFactor:CGFloat = 0.2

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gesture:)))
        longPressRecognizer.minimumPressDuration = 0.8
        //forceTouchView.addGestureRecognizer(longPressRecognizer)
        
        let forceTouchRecognizer = ForceGestureRecognizer(target: self, action: #selector(forceTouchAction(gesture:)))
        forceTouchView.addGestureRecognizer(forceTouchRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        print("maxValue is \(gesture.maxValue)")
        print(gesture.forceValue)
        if gesture.forceValue > 1{
            
                let scaleFactor = 1 + (((gesture.forceValue - 1) / gesture.maxValue) * maxScaleFactor)
            
                let scale = CGAffineTransform(scaleX: scaleFactor ,y: scaleFactor)
                forceTouchView.transform = scale
            
            if gesture.forceValue > 5{
                AudioServicesPlaySystemSound(1520)
                gesture.isEnabled = false
                let scale = CGAffineTransform(scaleX: 1, y: 1)
                forceTouchView.transform = scale
                gesture.isEnabled = true
            }
        }else{
            let scale = CGAffineTransform(scaleX: 1, y: 1)
            forceTouchView.transform = scale
        }
        
        if gesture.state == .ended{
            let scale = CGAffineTransform(scaleX: 1, y: 1)
            forceTouchView.transform = scale

        }
    }

}

