//
//  ColorScroll.swift
//  OpticScroll
//
//  Created by Shynkarenko Volodymyr on 4/14/19.
//  Copyright © 2019 Shynkarenko Volodymyr. All rights reserved.
//

import UIKit

class MyColorScroll: UIControl {
    
    // MARK: -
    // MARK: Public properties
    
    public var value : Float = 0.5
    public var minimumValue : Float = 0.0
    public var maximumValue : Float = 1.0
    public var minScrollValue : Float = 0.25
    public var maxScrollValue : Float = 0.75
    
    public var lineWidth : CGFloat = 1.0
    
    public var scrollCoordinates : MyCSValues<Float> = MyCSValues(values: [0.0, 0.25, 0.75, 1.0], doIfValueChenged: {})
    
    public var scrollColors : MyCSValues<UIColor> = MyCSValues(values: [.red, .orange, .green , .blue], doIfValueChenged: {})

    public var setThumbImage : UIImage {
        get {
            return self.thumbImage
        }
        set (newImage) {
            self.thumbImage = newImage
        }
    }
    
    public let thumb : UIButton = UIButton()
    
    // MARK: -
    // MARK: Private properties
    
    private let shape = CAShapeLayer()
    private var gradientLayer = CAGradientLayer()
    private var thumbImage : UIImage = UIImage(named: "2")!
    
 
    private var maxX : CGFloat {
        get {
            return self.bounds.maxX
        }
    }
    private var maxY : CGFloat {
        get {
            return self.bounds.maxY
        }
    }
    
    // MARK: -
    // MARK: Initialization
    
    override init(frame inputFrame: CGRect) {
        super.init(frame: inputFrame)
        prepareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareInit()
    }
    
    private func prepareInit(){
        self.lineWidth = self.maxY / 4
        let drawLine = lineWithCircle(self.value)
        self.gradientLayer = CAGradientLayer(layer: self.layer)
        self.scrollCoordinates.valueChanged = drawGradient
        self.scrollColors.valueChanged = drawGradient
        self.drawGradient()
        self.layer.addSublayer(self.gradientLayer)
        self.shape.path = drawLine.cgPath
        self.layer.mask = self.shape
        createThumb()
        self.addSubview(self.thumb)
    }
    
    private func createThumb() {
        let width = self.maxY - self.lineWidth
        let positionCenterTumb = valueToCoordinate(self.value)
        let frame = CGRect(x: self.bounds.minX + positionCenterTumb - width/2,
                           y: (self.bounds.maxY - self.bounds.minY - width)/2,
                           width: width,
                           height: width)
        self.thumb.frame = frame
        
        
        self.thumb.layer.cornerRadius = self.thumb.frame.height / 2
        
        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.addTarget(self, action: #selector(moveSlider(_:)))
        self.thumb.addGestureRecognizer(panRecognizer)
        self.thumb.setImage(self.thumbImage, for: .normal)
        self.thumb.showsTouchWhenHighlighted = true
        self.thumb.layer.borderColor = UIColor.black.cgColor
    }
    
    private func drawGradient() {
        self.gradientLayer.frame = self.bounds
        self.gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.gradientLayer.colors = self.scrollColors.values.map({ (ucolor) -> CGColor in
                return ucolor.cgColor})
        self.gradientLayer.locations = self.scrollCoordinates.values as [NSNumber]
    }
    
    private func lineWithCircle(_ coord: Float) -> UIBezierPath{
        let drawLine = UIBezierPath()
        drawLine.move(to: CGPoint(x: -2*maxX, y: self.maxY/2 - self.lineWidth/2))
        drawLine.addLine(to: CGPoint(x: 2*maxX, y: self.maxY/2-self.lineWidth/2))
        drawLine.addLine(to: CGPoint(x: 2*maxX, y: self.maxY/2+self.lineWidth/2))
        drawLine.addLine(to: CGPoint(x: -2*maxX, y: self.maxY/2+self.lineWidth/2))
        
        let positionCenterCircle = valueToCoordinate(self.value)
        drawLine.move(to: CGPoint(x: positionCenterCircle, y: maxY/2))
        drawLine.addArc(withCenter: CGPoint(x: positionCenterCircle, y: maxY / 2), radius: maxY / 2, startAngle: 0, endAngle: CGFloat.pi*2, clockwise: true)
        return drawLine
    }
    
    // MARK: -
    // MARK: Methods
    
    @objc private func moveSlider(_ sender: Any) {
        if ((sender as? UIPanGestureRecognizer) != nil) {
            let inputGesture = sender as! UIPanGestureRecognizer
            let translation = inputGesture.translation(in: self)
            if translation.x == 0 {return}
            let currentPosition = self.thumb.frame.midX
            self.sendActions(for: .valueChanged)
            self.thumb.center = CGPoint(x:self.thumb.center.x + translation.x, y:self.thumb.center.y)
            self.value = coordinateToValue(self.thumb.frame.midX)
            if self.value < self.minimumValue {
                self.value = self.minimumValue
                let newValueCenter = valueToCoordinate(self.value)
                self.thumb.center = CGPoint(x : newValueCenter, y:self.thumb.center.y)
            }
            if self.value > self.maximumValue {
                self.value = self.maximumValue
                let newValueCenter =  valueToCoordinate(self.value)
                self.thumb.center = CGPoint(x : newValueCenter, y:self.thumb.center.y)
            }
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            self.shape.position = CGPoint(x : self.shape.position.x + (self.thumb.frame.midX - currentPosition),
                y: self.shape.position.y )
            CATransaction.commit()
            inputGesture.setTranslation(CGPoint.zero, in: self)
        }
    }
    
    private func valueToCoordinate (_ value: Float) -> CGFloat {
        let scrollCoord = value * (self.maxScrollValue - self.minScrollValue) + self.minScrollValue
        let screenCoord = CGFloat(scrollCoord) * (self.bounds.maxX - self.bounds.minX) + self.bounds.minX
        return screenCoord
    }
    
    private func coordinateToValue (_ coord: CGFloat) -> Float {
        let screenValue = (coord - self.bounds.minX) / (self.bounds.maxX - self.bounds.minX)
        let scrollValue = (Float(screenValue) - self.minScrollValue) / (self.maxScrollValue - self.minScrollValue)
        return scrollValue
    }
    
    open func redraw() {
        let drawLine = lineWithCircle(self.value)
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        self.shape.position = CGPoint(x: 0, y: 0)
        self.shape.path = drawLine.cgPath
        CATransaction.commit()
        createThumb()
    }
}
