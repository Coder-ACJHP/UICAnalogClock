//
//  ViewController.swift
//  UICAnalogClock
//
//  Created by Onur Işık on 20.03.2019.
//  Copyright © 2019 Onur Işık. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var clockView: ClockView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clockView = ClockView.init(frame: view.frame)
        view.addSubview(clockView!)
    }

}

