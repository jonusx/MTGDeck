//
//  DeckBreakdownViewController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 6/4/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit
import Charts



class DeckBreakdownViewController: UIViewController {
    @IBOutlet weak var statsTable:UITableView?
    var deck:MTGDeck?
    
    var cells:[UITableViewCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = deck else { return }
        configureCells()
    }
    
    func configureCells() {
        let cell = statsTable?.dequeueReusableCellWithIdentifier("ManaDistributionCell") as! ManaDistributionCell
        cell.distributionPieChart?.data = StatsHelper.manaDistributionDataForDeck(deck!)
        cell.distributionPieChart?.centerText = "Mana\nDistribution"
        cells.append(cell)
        
        let curveCell = statsTable?.dequeueReusableCellWithIdentifier("ManaCurveCell") as! ManaCurveCell
        curveCell.manaCurveGraphView?.data = StatsHelper.manaCurveDataForDeck(deck!)
        curveCell.manaCurveGraphView?.descriptionText = "Mana Curve"
        cells.append(curveCell)
    }
}

extension DeckBreakdownViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
}
