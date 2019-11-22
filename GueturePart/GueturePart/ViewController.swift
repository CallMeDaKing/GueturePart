//
//  ViewController.swift
//  GueturePart
//
//  Created by new on 2019/11/22.
//  Copyright © 2019 king. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
 
    private var contentImage: UIImageView!
    private var gestureImage: UIImageView!
    private var lastCtrlPoint: CGPoint = CGPoint.zero
    private var originalPoint: CGPoint = CGPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let testImageView = PanGestureImageVIew.init(frame: CGRect.init(x: 100, y: 200, width: 200, height: 265))
        testImageView.image = UIImage(named: "testPic")
        self.view.addSubview(testImageView)
    }

}

