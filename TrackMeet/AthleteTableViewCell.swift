//
//  AthleteTableViewCell.swift
//  TrackMeet
//
//  Created by Brian Seaver on 2/28/21.
//  Copyright © 2021 clc.seaver. All rights reserved.
//

import UIKit

class AthleteTableViewCell: UITableViewCell {

    @IBOutlet weak var nameOutlet: UILabel!
    
    @IBOutlet weak var yearOutlet: UILabel!
    
    
    @IBOutlet weak var schoolOutlet: UILabel!
    
    func configure(){
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
