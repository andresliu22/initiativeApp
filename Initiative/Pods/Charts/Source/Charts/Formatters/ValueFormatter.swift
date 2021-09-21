//
//  ValueFormatter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

/// Interface that allows custom formatting of all values inside the chart before they are drawn to the screen.
///
/// Simply create your own formatting class and let it implement ValueFormatter. Then override the stringForValue()
/// method and return whatever you want.

@objc(ChartValueFormatter)
public protocol ValueFormatter: class
{
    
    /// Called when a value (from labels inside the chart) is formatted before being drawn.
    ///
    /// For performance reasons, avoid excessive calculations and memory allocations inside this method.
    ///
    /// - returns:                   The formatted label ready to be drawn
    ///
    /// - parameter value:           The value to be formatted
    ///
    /// - parameter dataSetIndex:    The index of the DataSet the entry in focus belongs to
    ///
    /// - parameter viewPortHandler: provides information about the current chart state (scale, translation, ...)
    ///
    func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String
}