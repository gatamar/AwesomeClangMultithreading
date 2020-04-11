//
//  ViewController.swift
//  ExploreRunLoops
//
//  Created by Olha Pavliuk on 11.04.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit
import CoreFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activities = CFOptionFlags(CFRunLoopActivity.allActivities.rawValue | CFRunLoopActivity.exit.rawValue)
        let loopMode = CFRunLoopMode.commonModes
        
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, activities, true, 0) { (observer, activity) in
            
            let time = CFAbsoluteTimeGetCurrent()
            
            switch activity {
                
            case .beforeTimers:
                print("Activity: before timers \(time)")
                
            case .beforeWaiting:
                print("Activity: before waiting \(time)")
            
            case .afterWaiting:
                print("Activity: after waiting \(time)")
                
            default:
                break
                //print(activity)
            
            }
        }
        
        let mainLoop: CFRunLoop! = CFRunLoopGetMain()
        
        CFRunLoopAddObserver(mainLoop, observer, loopMode)
        assert( CFRunLoopContainsObserver(mainLoop, observer, loopMode) )
        
        var context = CFRunLoopTimerContext(version: 0, info: unsafeBitCast(self, to: UnsafeMutableRawPointer.self), retain: nil, release: nil, copyDescription: nil)
        let fireDate = 0.1
        let interval = 2.0
        let timer = CFRunLoopTimerCreate(kCFAllocatorDefault, fireDate, interval, 0, 0, cfRunloopTimerCallback(), &context)
        CFRunLoopAddTimer(mainLoop, timer, loopMode)
        
        let nextTimerFireTime = CFRunLoopGetNextTimerFireDate(CFRunLoopGetMain(), loopMode)
        print("nextTimerFireTime = \(nextTimerFireTime)")
    }

    var colorMode: Int = 0
    fileprivate func updateViewColorOnTimer() {
        colorMode = (colorMode + 1) % 2
        view.backgroundColor = colorMode==0 ? .red : .blue
    }
    
    func cfRunloopTimerCallback() -> CFRunLoopTimerCallBack {
        return { (cfRunloopTimer, info) -> Void in
            print("Fire timer... \(CFAbsoluteTimeGetCurrent())")
            
            let grabSelf = unsafeBitCast(info, to: ViewController.self)
            grabSelf.updateViewColorOnTimer()
            
            // simulate really long op
            Thread.sleep(forTimeInterval: 3.0)
        }
    }
}

