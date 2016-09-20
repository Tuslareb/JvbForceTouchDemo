//
//  ForcetouchGestureRecognizer.swift
//  JvbForceTouchDemo
//
//  Created by Joost van Breukelen on 15-09-16.
//  Copyright © 2016 J.J.A.P. van Breukelen. All rights reserved.
//

import Foundation

import UIKit.UIGestureRecognizerSubclass

@available(iOS 9.0, *)
class ForceGestureRecognizer: UIGestureRecognizer {
    
    var forceValue: CGFloat = 0
    var maxValue: CGFloat!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
        handleForceWithTouches(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        state = .changed
        handleForceWithTouches(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
        handleForceWithTouches(touches: touches)
    }
    
    func handleForceWithTouches(touches: Set<UITouch>) {
        if touches.count != 1 {
            state = .failed
            return
        }
        guard let touch = touches.first else {
            state = .failed
            return
        }
        forceValue = touch.force
        maxValue = touch.maximumPossibleForce
    }
    
    //This is called when our state is set to .ended. 
    public override func reset() {
        super.reset()
        print("reset")
        forceValue = 0.0
    }
}
