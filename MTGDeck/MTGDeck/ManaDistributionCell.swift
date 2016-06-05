//
//  ManaDistributionCell.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 6/4/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit
import Charts

class ManaDistributionCell: UITableViewCell {
    @IBOutlet weak var distributionPieChart:PieChartView? {
        didSet {
            distributionPieChart?.usePercentValuesEnabled = true
            distributionPieChart?.drawSlicesUnderHoleEnabled = false
            distributionPieChart?.descriptionText = ""
            distributionPieChart?.highlightPerTapEnabled = true
            
            distributionPieChart?.legend.horizontalAlignment = .Right
            distributionPieChart?.legend.verticalAlignment = .Center
            distributionPieChart?.legend.orientation = .Vertical
            distributionPieChart?.drawCenterTextEnabled = true
        }
    }
}
