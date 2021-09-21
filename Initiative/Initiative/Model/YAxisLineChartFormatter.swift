//
//  YAxisLineChartFormatter.swift
//  Initiative
//
//  Created by Andres Liu on 1/4/21.
//

import UIKit
import Charts

public class YAxisLineChartFormatter: IndexAxisValueFormatter {
    public override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "$ \(abs(value.round(to: 2)))MM                          "
    }
}
