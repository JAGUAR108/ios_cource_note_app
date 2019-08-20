//
//  CheckMarkView.swift
//  Note
//
//  Created by Максим Бачурин on 12/07/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import Foundation
import UIKit

class CheckMarkView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {return}
        context.clear(rect)
        context.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                       radius: min(rect.width/3,
                                   rect.height/3),
                       startAngle: 0,
                       endAngle: CGFloat(Double.pi*2),
                       clockwise: true)
        context.move(to: CGPoint(x: rect.midX, y: rect.midY))
        context.addLine(to: CGPoint(x: rect.maxX - 2, y: rect.minY + 2))
        context.move(to: CGPoint(x: rect.midX + 1, y: rect.midY + 1))
        context.addLine(to: CGPoint(x: rect.midX/2, y: rect.midY/2))
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(3)
        context.strokePath()
    }
}
