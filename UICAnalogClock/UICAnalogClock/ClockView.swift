//
//  ClockView.swift
//  UICAnalogClock
//
//  Created by Onur Işık on 20.03.2019.
//  Copyright © 2019 Onur Işık. All rights reserved.
//

import UIKit

class ClockView: UIView {
    
    
    private let date = Date()
    private let cal = Calendar.current
    private var hour: Int!
    private var minute: Int!
    private var second: Int!
    
    private let hourLayer = CALayer()
    private let minuteLayer = CALayer()
    private let secondsLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isOpaque = true
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        if hour == nil && minute == nil && second == nil {
            
            hour = cal.component(.hour, from: date)
            minute = cal.component(.minute, from: date)
            second = cal.component(.second, from: date)
        }
        
        self.drawBorderCircle(forRectangle: rect)
    }
    
    fileprivate func degreeToRadian(degree: CGFloat) -> CGFloat {
        let result = CGFloat(Double.pi) * degree / 180
        return result
    }
    
    func circleCircumferencePoints(sides:Int, x:CGFloat, y:CGFloat, radius:CGFloat, adjustment: CGFloat=0) -> [CGPoint] {
        
        let angle = degreeToRadian(degree: 360 / CGFloat(sides))
        let cx = x // x origin
        let cy = y // y origin
        let r  = radius // radius of circle
        var i = sides
        var points = [CGPoint]()
        while points.count <= sides {
            let xpo = cx - r * cos(angle * CGFloat(i) + degreeToRadian(degree: adjustment))
            let ypo = cy - r * sin(angle * CGFloat(i) + degreeToRadian(degree: adjustment))
            points.append(CGPoint(x: xpo, y: ypo))
            i -= 1
        }
        return points
    }
    
    fileprivate func drawSecondsMarker(context: CGContext, x: CGFloat, y: CGFloat, radius: CGFloat, sides: Int, color: UIColor) {
        
        let points = circleCircumferencePoints(sides: sides,x: x,y: y,radius: radius)

        let path = CGMutablePath()

        var divider:CGFloat = 1 / 16
        for (index, point) in points.enumerated() {
            
            if index % 5 == 0 { divider = 1 / 8 }
            else { divider = 1 / 16 }
            
            let xn = point.x + divider * (x - point.x)
            let yn = point.y + divider * (y - point.y)
            
            path.move(to: CGPoint(x: point.x, y: point.y))
            path.addLine(to: CGPoint(x: xn, y: yn))
            path.closeSubpath()
            
            context.addPath(path)
        }
        
        context.setLineWidth(2.0)
        context.setStrokeColor(color.cgColor)
        context.strokePath()
    }
    
    fileprivate func drawNumbers(rect: CGRect, context: CGContext, x: CGFloat, y: CGFloat, radius: CGFloat, sides: Int, color: UIColor) {
        
        context.translateBy(x: 0, y: rect.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let inset: CGFloat = radius / 3.5
        let points = circleCircumferencePoints(sides: sides,x: x, y: y, radius: radius - inset, adjustment: 270)
        
        for (index, point) in points.enumerated() {
            
            if index > 0 {
                
                let font = UIFont(name: "Optima-Bold", size: radius / 5)!
                let attributes = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: color]
                let attributedString = NSAttributedString(string: index.description, attributes: attributes)
                let line = CTLineCreateWithAttributedString(attributedString)
                let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
                
                context.setLineWidth(1.5)
                context.setTextDrawingMode(.stroke)
                
                let xn = point.x - bounds.width / 2
                let yn = point.y - bounds.midY
                
                context.textPosition = CGPoint(x: xn, y: yn)
                CTLineDraw(line, context)
                
            }
        }
    }
    
    fileprivate func drawHands(rect: CGRect, context: CGContext, x: CGFloat, y: CGFloat, radius: CGFloat) {
        
        let bounds = radius / 10
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(x: x - bounds / 2, y: y - bounds / 2, width: bounds, height: bounds))
        
        let hourAngle: CGFloat = CGFloat(Double(hour) * (360.0 / 12.0)) + CGFloat(Double(minute) * (1.0 / 60.0) * (360.0 / 12.0))
        let minuteAngle: CGFloat = CGFloat(minute) * CGFloat(360.0 / 60.0)
        let secondsAngle: CGFloat = CGFloat(second) * CGFloat(360.0 / 60.0)
        
        let mainLayer = CALayer()
        mainLayer.frame = rect
        
        hourLayer.backgroundColor = UIColor.black.cgColor
        hourLayer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        hourLayer.position = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        hourLayer.bounds = CGRect(x: 0, y: 0, width: 5, height: mainLayer.frame.size.width * 0.18)
        hourLayer.transform = CATransform3DMakeRotation(hourAngle / 180 * CGFloat(Double.pi), 0, 0, 1)
        mainLayer.addSublayer(hourLayer)
        self.layer.addSublayer(mainLayer)
        
        let hourAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        hourAnimation.repeatCount = .infinity
        hourAnimation.duration = 60 * 60 * 12
        hourAnimation.isRemovedOnCompletion = false
        hourAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        hourAnimation.fromValue = -hourAngle * CGFloat(Double.pi) / 180.0
        hourAnimation.byValue = -2 * Double.pi
        hourLayer.add(hourAnimation, forKey: "HourAnimationKey")
        
        minuteLayer.backgroundColor = UIColor.black.cgColor
        minuteLayer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        minuteLayer.position = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        minuteLayer.bounds = CGRect(x: 0, y: 0, width: 6, height: mainLayer.frame.size.width * 0.23)
        minuteLayer.transform = CATransform3DMakeRotation(minuteAngle / 180 * CGFloat(Double.pi), 0, 0, 1);
        mainLayer.addSublayer(minuteLayer)
        
        let minutesAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        minutesAnimation.repeatCount = .infinity
        minutesAnimation.duration = 60 * 60
        minutesAnimation.isRemovedOnCompletion = false
        minutesAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        minutesAnimation.fromValue = -minuteAngle * CGFloat(Double.pi) / 180.0
        minutesAnimation.byValue = -2 * Double.pi
        minuteLayer.add(minutesAnimation, forKey: "MinuteAnimationKey")
        
        secondsLayer.backgroundColor = UIColor.red.cgColor
        secondsLayer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        secondsLayer.position = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        secondsLayer.bounds = CGRect(x: 0, y: 0, width: 3, height: mainLayer.frame.size.width * 0.28)
        secondsLayer.transform = CATransform3DMakeRotation(secondsAngle / 180 * CGFloat(Double.pi), 0, 0, 1);
        mainLayer.addSublayer(secondsLayer)
        
        let secondsAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        secondsAnimation.repeatCount = .infinity
        secondsAnimation.duration = 60
        secondsAnimation.isRemovedOnCompletion = false
        secondsAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        secondsAnimation.fromValue = secondsAngle * CGFloat(Double.pi) / 180.0
        secondsAnimation.byValue = 2 * Double.pi
        secondsLayer.add(secondsAnimation, forKey: "SecondAnimationKey")
    }
    
    fileprivate func drawBorderCircle(forRectangle: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()!

        let radius = forRectangle.width / 3.5
        let endAngle = CGFloat(Double.pi * 2)
        let centerPoint = CGPoint(x: forRectangle.midX, y: forRectangle.midY)
        context.addArc(center: centerPoint, radius: radius, startAngle: 0, endAngle: endAngle, clockwise: true)
        context.setFillColor(UIColor.lightGray.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(4.0)
        context.drawPath(using: .fillStroke)
        
        self.drawSecondsMarker(context: context, x: forRectangle.midX, y: forRectangle.midY, radius: radius, sides: 60, color: .white)
        
        self.drawNumbers(rect: forRectangle, context: context, x: forRectangle.midX, y: forRectangle.midY, radius: radius, sides: 12, color: .white)
        
        self.drawHands(rect: forRectangle, context: context, x: forRectangle.midX, y: forRectangle.midY, radius: radius)
        
    }

}
