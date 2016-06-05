//
//  ManaCurveCell.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 6/4/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit
import Charts

class ManaCurveCell: UITableViewCell {
    @IBOutlet weak var manaCurveGraphView:CombinedChartView? {
        didSet {
            manaCurveGraphView?.drawOrder = [DrawOrder.Bar.rawValue, DrawOrder.Line.rawValue]
            manaCurveGraphView?.leftAxis.drawGridLinesEnabled = false
            manaCurveGraphView?.leftAxis.drawLabelsEnabled = false
            manaCurveGraphView?.rightAxis.drawGridLinesEnabled = false
            manaCurveGraphView?.rightAxis.drawLabelsEnabled = false
            manaCurveGraphView?.legend.enabled = false
            manaCurveGraphView?.descriptionText = ""
        }
    }

}
