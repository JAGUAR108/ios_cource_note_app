//
//  ColorPickerView.swift
//  
//
//  Created by Максим Бачурин on 11/07/2019.
//

import Foundation
import UIKit

internal protocol ColorPickerDelegate: NSObjectProtocol {
    func newColor(sender: ColorPickerView, color: UIColor)
    func changedColor(sender: ColorPickerView, color: UIColor)
}

class ColorPickerView: UIView, ColorPickerMapViewDelegate {
    weak internal var delegate: ColorPickerDelegate?
    var currentColorView: UIView?
    var labelBrightness: UILabel?
    var sliderBrightness: UISlider?
    var colorPickerMapView: ColorPickerMapView?
    var buttonDone: UIButton?
    
    //MARK: - Inits
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    func initialize() {
        initializeCurrentColorView()
        initializeLabelBrightness()
        initializeColorPickerMapView()
        initializeSliderBrightness()
        initializeButtonDone()
        createConstraints()
    }
    
    func installColor(color: UIColor) {
        currentColorView?.backgroundColor = color
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        sliderBrightness?.value = Float(brightness)
        let point = CGPoint(x: hue * CGFloat(colorPickerMapView!.bounds.width),
                            y: saturation * CGFloat(colorPickerMapView!.bounds.height))
        colorPickerMapView?.colorPickerCursorView?.update(position: point, brightness: brightness)
        colorPickerMapView?.setBrightness(brightness)
    }
    
    func initializeCurrentColorView() {
        currentColorView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        currentColorView?.backgroundColor = .white
        currentColorView?.layer.borderColor = UIColor.black.cgColor
        currentColorView?.layer.borderWidth = 1
        currentColorView?.layer.cornerRadius = 10
        self.addSubview(currentColorView!)
    }
    
    func initializeLabelBrightness() {
        labelBrightness = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        labelBrightness?.text = "Brightness:"
        self.addSubview(labelBrightness!)
    }
    
    func initializeSliderBrightness(brightness: Float = 1) {
        sliderBrightness = UISlider(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        sliderBrightness?.minimumValue = 0
        sliderBrightness?.maximumValue = 1
        sliderBrightness?.value = brightness
        sliderBrightness?.addTarget(self, action: #selector(sliderChange), for: .valueChanged)
        
        self.addSubview(sliderBrightness!)
    }
    
    func initializeColorPickerMapView() {
        colorPickerMapView = ColorPickerMapView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        colorPickerMapView?.layer.borderColor = UIColor.black.cgColor
        colorPickerMapView?.layer.borderWidth = 1
        colorPickerMapView?.delegate = self
        self.addSubview(colorPickerMapView!)
        
    }
    
    func initializeButtonDone() {
        buttonDone = UIButton(type: .system)
        buttonDone?.setTitle("Done", for: .normal)
        self.addSubview(buttonDone!)
        buttonDone?.addTarget(self, action: #selector(tapButtonDone(_:)), for: .touchUpInside)
    }
    
    //MARK: - Constrains
    func createConstraints() {
        currentColorView?.translatesAutoresizingMaskIntoConstraints = false
        labelBrightness?.translatesAutoresizingMaskIntoConstraints = false
        sliderBrightness?.translatesAutoresizingMaskIntoConstraints = false
        colorPickerMapView?.translatesAutoresizingMaskIntoConstraints = false
        buttonDone?.translatesAutoresizingMaskIntoConstraints = false
        currentColorView?.leftAnchor.constraint(equalTo: self.leftAnchor,
                                                constant: 8).isActive = true
        currentColorView?.topAnchor.constraint(equalTo: self.topAnchor,
                                               constant: 8).isActive = true
        currentColorView?.rightAnchor.constraint(equalTo: labelBrightness!.leftAnchor,
                                                 constant: -8).isActive = true
        currentColorView?.heightAnchor.constraint(equalToConstant: self.bounds.size.width/4).isActive = true
        currentColorView?.heightAnchor.constraint(equalTo: currentColorView!.widthAnchor,
                                                  multiplier: 1).isActive = true
        
        labelBrightness?.topAnchor.constraint(equalTo: currentColorView!.topAnchor).isActive = true
        labelBrightness?.rightAnchor.constraint(equalTo: self.rightAnchor,
                                                constant: -8).isActive = true
        sliderBrightness?.topAnchor.constraint(equalTo: labelBrightness!.bottomAnchor,
                                               constant: 8).isActive = true
        sliderBrightness?.leftAnchor.constraint(equalTo: labelBrightness!.leftAnchor).isActive = true
        sliderBrightness?.rightAnchor.constraint(equalTo: labelBrightness!.rightAnchor).isActive = true
        colorPickerMapView?.topAnchor.constraint(equalTo: currentColorView!.bottomAnchor, constant: 8).isActive = true
        colorPickerMapView?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        colorPickerMapView?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        colorPickerMapView?.bottomAnchor.constraint(equalTo: buttonDone!.topAnchor, constant: -8).isActive = true
        buttonDone?.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        buttonDone?.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        buttonDone?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
    }
    
    //MARK: ColorPickerMapViewDelegate
    func changeColor(sender: ColorPickerMapView, color: UIColor) {
        currentColorView?.backgroundColor = color
        delegate?.changedColor(sender: self, color: color)
    }
    
    //MARK:  - Selectors
    @objc func sliderChange(_ sender: UISlider) {
        colorPickerMapView?.setBrightness(CGFloat(sender.value))
        colorPickerMapView?.colorPickerCursorView?.update(brightness: CGFloat(sender.value))
        currentColorView?.backgroundColor = colorPickerMapView?.colorPickerCursorView?.currentColor
    }
    
    @objc func tapButtonDone(_ sender: UITapGestureRecognizer) {
        delegate?.newColor(sender: self, color: currentColorView?.backgroundColor ?? UIColor.white)
    }
}

internal protocol ColorPickerMapViewDelegate: NSObjectProtocol {
    func changeColor(sender: ColorPickerMapView, color: UIColor)
}

class ColorPickerMapView: UIView {
    internal weak var delegate: ColorPickerMapViewDelegate?
    private var brightness: CGFloat = 1
    private var elementSize:CGFloat = 3.0
    private var panGesture: UIPanGestureRecognizer?
    private var tapGesture: UITapGestureRecognizer?
    var colorPickerCursorView: ColorPickerCursorView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    func initialize() {
        self.clipsToBounds = true
        initializeColorPickerCursorView()
        initializePanGesture()
        initializeTapGesture()
    }
    
    func setBrightness(_ brightness: CGFloat) {
        self.brightness = brightness
        setNeedsDisplay()
    }
    
    func initializeColorPickerCursorView() {
        colorPickerCursorView = ColorPickerCursorView(frame: CGRect(x: 0,
                                                                    y: 0,
                                                                    width: self.bounds.size.width/3,
                                                                    height: self.bounds.size.height/3))
        self.addSubview(colorPickerCursorView!)
    }
    
    func initializePanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(gestureAction(_:)))
        self.addGestureRecognizer(panGesture!)
    }
    
    func initializeTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(gestureAction(_:)))
        self.addGestureRecognizer(tapGesture!)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for y : CGFloat in stride(from: CGFloat(0.0) ,to: rect.height, by: elementSize) {
            let saturation = y/rect.height
            for x : CGFloat in stride(from: 0.0 ,to: rect.width, by: elementSize) {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(x:x, y:y, width:elementSize,height:elementSize))
            }
        }
    }
    
    @objc func gestureAction(_ sender: UIGestureRecognizer) {
        //print("Pan")
        let currentPoint = sender.location(in: self)
        colorPickerCursorView?.update(position: currentPoint,
                                      brightness: brightness)
        delegate?.changeColor(sender: self, color: colorPickerCursorView?.currentColor ?? UIColor.white)
    }
}

class ColorPickerCursorView: UIView {
    var currentColor: UIColor = .white
    private var point: CGPoint = CGPoint.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        //self.backgroundColor = .clear
        self.layer.sublayers = []
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: point.x,
                                                         y: point.y),
                                      radius: min(self.bounds.width,
                                                  self.bounds.height)/2,
                                      startAngle: CGFloat(0),
                                      endAngle: CGFloat(Double.pi*2),
                                      clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = currentColor.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = min(self.bounds.width,
                                   self.bounds.height)/10
        self.layer.addSublayer(shapeLayer)
    }
    
    func update(position: CGPoint = CGPoint.zero, brightness: CGFloat) {
        if !position.equalTo(.zero) {
            point = position
        }
        //print(point.x, point.x/self.superview!.bounds.size.height, point.y, point.y/self.superview!.bounds.size.width)
        currentColor = UIColor(hue: point.x/self.superview!.bounds.size.width,
                               saturation: point.y/self.superview!.bounds.size.height,
                               brightness: brightness, alpha: 1)
        initialize()
    }
}
