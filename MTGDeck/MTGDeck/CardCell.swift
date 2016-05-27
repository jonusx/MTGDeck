//
//  CardCell.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/22/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {
    @IBOutlet weak var nameLabel:UILabel?
    @IBOutlet weak var typeLabel:UILabel?
    @IBOutlet weak var cardTextLabel:UILabel?
    @IBOutlet weak var cardArtImageView:UIImageView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cardArtImageView?.image = nil
    }
}
