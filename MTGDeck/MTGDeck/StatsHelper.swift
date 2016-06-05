//
//  StatsHelper.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 6/4/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit
import Charts

class StatsHelper {
    static func manaCurveDataForDeck(deck:MTGDeck) -> CombinedChartData {
        let chartData = CombinedChartData(xVals: (0...deck.curveBreakDown!.maxCost).map { String($0) })
        let lineChartData = LineChartData()
        let entries:[ChartDataEntry] = (0...deck.curveBreakDown!.maxCost).map { (count) -> ChartDataEntry in
            return ChartDataEntry(value: Double(deck.curveBreakDown![count]), xIndex: count)
        }
        let color = UIColor.blackColor()
        let lineData = LineChartDataSet(yVals: entries, label: nil)
        lineData.lineWidth = 2
        lineData.drawValuesEnabled = false
        lineData.setCircleColor(color)
        lineData.setColor(color)
        lineData.mode = .HorizontalBezier
        lineData.circleRadius = 2
        lineChartData.addDataSet(lineData)
        chartData.lineData = lineChartData
        
        let barData = BarChartData()
        let barEntries:[BarChartDataEntry] = (0...deck.curveBreakDown!.maxCost).map { (count) -> BarChartDataEntry in
            return BarChartDataEntry(value: Double(deck.curveBreakDown![count]), xIndex: count)
        }
        let barDataSet = BarChartDataSet(yVals: barEntries, label: nil)
        barDataSet.axisDependency = .Left
        barData.addDataSet(barDataSet)
        
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 1
        barData.setValueFormatter(formatter)
        chartData.barData = barData
        return chartData
    }
    
    static func manaDistributionDataForDeck(deck:MTGDeck) -> PieChartData {
        var entries:[ChartDataEntry] = []
        var xVals:[String?] = []
        var colors:[UIColor] = []
        
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .PercentStyle
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        formatter.percentSymbol = " %"
        
        let total = deck.colorBreakDown!.totalMana()
        if let count = deck.colorBreakDown?.red where count > 0 {
            entries.append(BarChartDataEntry(value: Double(count / total), xIndex: 0))
            xVals.append("Red")
            colors.append(UIColor.redColor())
        }
        if let count = deck.colorBreakDown?.white where count > 0 {
            entries.append(BarChartDataEntry(value: Double(count / total), xIndex: 1))
            xVals.append("White")
            colors.append(UIColor.whiteColor())
        }
        if let count = deck.colorBreakDown?.green where count > 0 {
            entries.append(BarChartDataEntry(value: Double(count / total), xIndex: 2))
            xVals.append("Green")
            colors.append(UIColor.greenColor())
        }
        if let count = deck.colorBreakDown?.black where count > 0 {
            entries.append(BarChartDataEntry(value: Double(count / total), xIndex: 3))
            xVals.append("Black")
            colors.append(UIColor.blackColor())
        }
        if let count = deck.colorBreakDown?.blue where count > 0 {
            entries.append(BarChartDataEntry(value: Double(count / total), xIndex: 4))
            xVals.append("Blue")
            colors.append(UIColor.blueColor())
        }
        if let count = deck.colorBreakDown?.colorless where count > 0 {
            entries.append(BarChartDataEntry(value: Double(count / total), xIndex: 5))
            xVals.append("Colorless")
            colors.append(UIColor.lightGrayColor())
        }
        
        let data = PieChartDataSet(yVals: entries, label: "")
        data.valueLineColor = UIColor.blackColor()
        data.valueLineWidth = 2.0
        data.colors = colors
        data.valueFormatter = formatter
        return PieChartData(xVals: xVals, dataSets: [data])
    }
}