//
//  PanGestureImageVIew.swift
//  GueturePart
//
//  Created by new on 2019/11/22.
//  Copyright © 2019 king. All rights reserved.
//

import UIKit

class PanGestureImageVIew: UIImageView {
    
    private let optionButton: UIButton = UIButton()
    private var lastCtrlPoint: CGPoint = CGPoint.zero
    private var originalPoint: CGPoint = CGPoint.zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        originalPoint = CGPoint.init(x: 0.5, y: 0.5);  //默认参考点为中心点
        optionButton.setBackgroundImage(UIImage(named: "prepare_rotation"), for: .normal)
    }
    
     override func layoutSubviews() {
        
        self.isUserInteractionEnabled = true
            
        optionButton.frame = CGRect.init(x:self.frame.size.width - 5, y: self.frame.size.height - 5, width: 22, height: 22)
        optionButton.layer.masksToBounds = true
        optionButton.layer.cornerRadius = 11
        optionButton.autoresizingMask = .flexibleLeftMargin
        addSubview(optionButton)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panImage(gesture:)))
        self.addGestureRecognizer(panGesture)
        
        let opentionPanGesture = UIPanGestureRecognizer(target: self, action: #selector(opentionPanImage(gesture:)))
        optionButton.addGestureRecognizer(opentionPanGesture)
        
        panGesture.require(toFail: opentionPanGesture)
            
    }
    
    @objc func panImage(gesture: UIPanGestureRecognizer) {
          
        if gesture.state == .changed {
            let translation = gesture.translation(in: self.superview!)
            self.center = CGPoint.init(x: self.center.x + translation.x, y: self.center.y + translation.y)
            
          if self.center.y >= (superview?.bounds.height)! - self.bounds.height / 2 {
                self.center = CGPoint(x: self.center.x, y: superview!.bounds.height - self.bounds.height / 2)
            }
            if self.center.y <= self.bounds.height / 2{
                self.center = CGPoint(x: self.center.x, y: self.bounds.height / 2)
            }
            if self.center.x >= superview!.bounds.width - self.bounds.width / 2{
                self.center = CGPoint(x: superview!.bounds.width - self.bounds.width / 2, y: self.center.y)
            }
            if self.center.x <= self.bounds.width / 2 {
                self.center = CGPoint(x: self.bounds.width / 2, y: self.center.y)
            }
            gesture.setTranslation(CGPoint.zero, in: self.superview)
        }
      }
      
    @objc func opentionPanImage(gesture: UIPanGestureRecognizer) {
          
        if gesture.view == self {
            return
        }

        if gesture.state == .began {
            lastCtrlPoint = self.convert(self.optionButton.center, to: self.optionButton.superview?.superview)
            return
        }
        
        let gesturePoint = gesture.location(in: self)
        
        let ctrlPoint = self.convert(gesturePoint, to: self.superview)
        
        // scale
        scaleFitWithCtrlPoint(ctrlPoint: ctrlPoint)
        // rotate
        rotateAroundOPointWithCtrlPoint(ctrlPoint: ctrlPoint)
        lastCtrlPoint = ctrlPoint
        
        gesture.setTranslation(CGPoint.zero, in: self.superview)
    }
      
    @objc func scaleFitWithCtrlPoint(ctrlPoint: CGPoint) {

        var oPoint = self.convert(self.getRealOriginalPoint(), to: self.superview)
        self.center = oPoint
        
        let preDistance = self.distanceWithStartPoint(startPoint: self.center, endPoint: self.lastCtrlPoint)
        let newDistance = self.distanceWithStartPoint(startPoint: self.center, endPoint: ctrlPoint)
        let scale =  newDistance / preDistance
        if self.bounds.size.width * scale > superview!.bounds.width || self.bounds.size.height > superview!.bounds.height {
            return
        }
            
        self.transform = self.transform.scaledBy(x: scale, y: scale)
        
        oPoint = self.convert(self.getRealOriginalPoint(), to: self.superview)
        self.center = CGPoint.init(x: self.center.x + (self.center.x - oPoint.x), y: self.center.y + (self.center.y - oPoint.y))
    }
    
    @objc func distanceWithStartPoint(startPoint: CGPoint, endPoint: CGPoint) -> CGFloat {
        
        let x = startPoint.x - endPoint.x
        let y = startPoint.y - endPoint.y
        return sqrt(x * x + y * y)
    }
      
    @objc func rotateAroundOPointWithCtrlPoint(ctrlPoint: CGPoint) {
        
        var oPoint = self.convert(self.getRealOriginalPoint(), to: self.superview)
        self.center = CGPoint.init(x: self.center.x - (self.center.x - oPoint.x), y: self.center.y - (self.center.y - oPoint.y))
        var angle = atan2(self.center.y - ctrlPoint.y, ctrlPoint.x - self.center.x)
        let lastAngle = atan2(self.center.y - self.lastCtrlPoint.y, self.lastCtrlPoint.x - self.center.x)
        angle = -angle + lastAngle
        
        self.transform = self.transform.rotated(by: angle);
        
        oPoint = self.convert(self.getRealOriginalPoint(), to: self.superview)
        self.center = CGPoint.init(x: self.center.x + (self.center.x - oPoint.x), y: self.center.y + (self.center.y - oPoint.y))
    }
      
    @objc func getRealOriginalPoint() -> CGPoint {
          
        return CGPoint.init(x: self.bounds.size.width * self.originalPoint.x, y: self.bounds.size.height * self.originalPoint.y)
      }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, with: event)
        if hitView == nil {
            let newpoint = self.optionButton.convert(point, from: self)
            if self.optionButton.bounds.contains(newpoint) {
                hitView = self.optionButton
            }
        }
        return hitView
    }
}


extension PanGestureImageVIew: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
