//
//  AthleteResultsTableViewCell.swift
//  TrackMeet
//
//  Created by Brian Seaver on 7/16/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import UIKit

class AthleteResultsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventOutlet: UILabel!
    @IBOutlet weak var meetOutlet: UILabel!
    @IBOutlet weak var dateOutlet: UILabel!
    @IBOutlet weak var markOutlet: UILabel!
    @IBOutlet weak var placeOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
