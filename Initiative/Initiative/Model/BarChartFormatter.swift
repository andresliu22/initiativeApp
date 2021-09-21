//
//  BarChartFormatter.swift
//  Initiative
//
//  Created by Andres Liu on 11/30/20.
//

import UIKit
import Charts

//@objc(BarChartFormatter)
//public class BarChartFormatter: NSObject, IAxisValueFormatter
//{
//    var names = [String]()
//
//    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
//    {
//        return names[Int(value)]
//    }
//
//    public func setValues(values: [String])
//    {
//        self.names = values
//    }
//}

public class BarChartAboveBarValueRenderer: BarChartRenderer {
    public override func initBuffers() {
        super.initBuffers()
    }
    
    public override func drawData(context: CGContext) {
        initBuffers()
        super.drawData(context: context.self)
    }
    
    public override func drawValue(context: CGContext, value: String, xPos: CGFloat, yPos: CGFloat, font: NSUIFont, align: NSTextAlignment, color: NSUIColor, anchor: CGPoint, angleRadians: CGFloat) {
        super.drawValue(context: context.self, value: value.self, xPos: xPos.self, yPos: yPos.self - 40, font: font.self, align: align.self, color: color.self, anchor: CGPoint(x: -1.2, y: 0), angleRadians: angleRadians.self)
        
    }
}

public class BarChartEstadoDeCuentaRenderer: BarChartRenderer {
    public override func initBuffers() {
        super.initBuffers()
    }
    
    public override func drawData(context: CGContext) {
        initBuffers()
        super.drawData(context: context.self)
    }
    
    public override func drawValue(context: CGContext, value: String, xPos: CGFloat, yPos: CGFloat, font: NSUIFont, align: NSTextAlignment, color: NSUIColor, anchor: CGPoint, angleRadians: CGFloat) {
        super.drawValue(context: context.self, value: value.self, xPos: xPos.self, yPos: yPos.self - 35, font: font.self, align: align.self, color: color.self, anchor: CGPoint(x: -1.2, y: 0), angleRadians: angleRadians.self)
        
    }

}

public class BarChartEstadoDeCuentaContratosRenderer: BarChartRenderer {
    public override func initBuffers() {
        super.initBuffers()
    }
    
    public override func drawData(context: CGContext) {
        initBuffers()
        super.drawData(context: context.self)
    }
    
    public override func drawValue(context: CGContext, value: String, xPos: CGFloat, yPos: CGFloat, font: NSUIFont, align: NSTextAlignment, color: NSUIColor, anchor: CGPoint, angleRadians: CGFloat) {
        super.drawValue(context: context.self, value: value.self, xPos: xPos.self, yPos: yPos.self - 20, font: font.self, align: align.self, color: color.self, anchor: CGPoint(x: -0.7, y: 0), angleRadians: angleRadians.self)
        
    }
}
