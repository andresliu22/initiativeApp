//
//  BarChartCollectionViewCell.swift
//  Initiative
//
//  Created by Andres Liu on 11/9/20.
//

import UIKit
import Charts
class BarChartCollectionViewCell: UICollectionViewCell {
    let barChartView = BarChartView()
    var graphicColors: [UIColor] = [UIColor(rgb: 0x7F2246), UIColor(rgb: 0xD93251), UIColor(rgb: 0x3F7F91), UIColor(rgb: 0x2C274C), UIColor(rgb: 0x3F7791), UIColor(rgb: 0x42173E), UIColor(rgb: 0xA3294A), UIColor(rgb: 0x37547F)]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(barChartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func listBarChart(graphData: [GraphElement], size: Int){
        
        barChartView.frame = CGRect(x: 0, y: 0, width: size, height: 300)
        
        barChartView.legend.enabled = false
//        barChart.setVisibleXRangeMaximum(5)
//        barChart.drawBordersEnabled = false
//        barChart.rightAxis.enabled = false
//
//        //barChart.xAxis.enabled = false
//        //barChart.xAxis.drawLabelsEnabled = false
//        //barChart.xAxis.labelPosition = .top
//        barChart.scaleXEnabled = false
//        barChart.scaleYEnabled = false
//        //barChart.highlightPerTapEnabled = true
//        barChart.dragEnabled = true
//        barChart.fitBars = true
//        barChart.drawValueAboveBarEnabled = true
//        barChart.animate(yAxisDuration: 0.5)
//
//        let xaxis = barChart.xAxis
//        xaxis.drawGridLinesEnabled = false
//        xaxis.labelPosition = .topInside
//        xaxis.labelRotationAngle = 270.0
//        xaxis.labelTextColor = UIColor.black
//        xaxis.centerAxisLabelsEnabled = true
//        xaxis.axisLineColor = UIColor.black
//        xaxis.granularityEnabled = true
//        xaxis.enabled = true
//
//        let yaxis = barChart.leftAxis
//        barChart.leftAxis.enabled = false
//        yaxis.spaceTop = 0.35
//        yaxis.axisMinimum = 0
//        yaxis.drawGridLinesEnabled = false
//        yaxis.labelTextColor = UIColor.black
//        yaxis.axisLineColor = UIColor.black
//        yaxis.labelPosition = .outsideChart
//        yaxis.enabled = false
        //barChart.xAxis.drawGridLinesEnabled = false
        //barChart.xAxis.enabled = true
        //barChart.xAxis.axisLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        //barChart.xAxis.granularityEnabled = false
        //barChart.xAxis.granularity = 1
        //barChart.xAxis.labelPosition = .bottom
        
        
        //barChart.leftAxis.axisMinimum = 0
        //barChart.leftAxis.granularity = 1
        //barChart.leftAxis.granularityEnabled = true
        //barChart.leftAxis.drawGridLinesEnabled = false
        //barChart.leftAxis.axisLineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        //barChart.rightAxis.enabled = false
        //barChart.rightAxis.drawGridLinesEnabled = false
        
        // Y - Axis Setup
            let yaxis = barChartView.leftAxis
            yaxis.spaceTop = 0.35
            yaxis.axisMinimum = 0
            yaxis.drawGridLinesEnabled = false
            yaxis.labelTextColor = UIColor.white
            yaxis.axisLineColor = UIColor.white
            yaxis.labelPosition = .insideChart
            yaxis.enabled = false
           // YAxis leftAxis = barChart.getAxisLeft();
        barChartView.rightAxis.enabled = false

            // X - Axis Setup
            let xaxis = barChartView.xAxis

            xaxis.drawGridLinesEnabled = false
            xaxis.labelPosition = .top
            xaxis.labelTextColor = UIColor.white
            xaxis.centerAxisLabelsEnabled = true
            xaxis.axisLineColor = UIColor.white
            xaxis.granularityEnabled = true
            xaxis.enabled = true
        
        var entries = [BarChartDataEntry]()
        
        
        for x in 1..<graphData.count {
            

            entries.append(BarChartDataEntry(x: Double(x) + 1, y: Double(graphData[x].amount / 1000000).round(to: 2)))
        }
        
        let set = BarChartDataSet(values: entries, label: "1")
        set.drawValuesEnabled = false
        set.colors = self.graphicColors
        set.valueColors = [.black]
        let chartData = BarChartData(dataSet: set)
        chartData.barWidth = Double(0.5)
        barChartView.data = chartData

        

        let groupSpace = 0.1
        let barSpace = 0.01
        let barWidth = 0.4

        chartData.barWidth = barWidth
        chartData.setDrawValues(true)
        barChartView.xAxis.axisMinimum = 0.0
        barChartView.xAxis.axisMaximum = 0.0 + chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(graphData.count)

        chartData.groupBars(fromX: 0.0, groupSpace: groupSpace, barSpace: barSpace)
        barChartView.xAxis.granularity = barChartView.xAxis.axisMaximum / Double(graphData.count)
        barChartView.drawValueAboveBarEnabled = true
        barChartView.keepPositionOnRotation = true
        barChartView.clipValuesToContentEnabled = true
        barChartView.data = chartData
        //barChartView.getAxis(.left).inverted = true

        barChartView.notifyDataSetChanged()
        barChartView.setVisibleXRangeMaximum(4)
        barChartView.animate(yAxisDuration: 1.0, easingOption: .linear)
        chartData.setValueTextColor(UIColor.black)
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
