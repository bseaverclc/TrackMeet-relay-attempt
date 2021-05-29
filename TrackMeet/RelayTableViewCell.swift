//
//  RelayTableViewCell.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/15/21.
//  Copyright © 2021 clc.seaver. All rights reserved.
//


import UIKit
public class RelayTableViewCell : UITableViewCell{
    
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var timeOutlet: UITextField!
    
    
    func configure(ath: Athlete, ev : Event){
        
        nameOutlet.text = "\(ath.last), \(ath.first)"
        timeOutlet.placeholder = "Split"
        timeOutlet.text = ev.markString
        
        if Meet.canCoach{
            timeOutlet.isEnabled = true
        }
        else{
            timeOutlet.isEnabled = false
        }
        
    }
    
    func configure(){
        nameOutlet.text = "Empty"
        timeOutlet.text = ""
        timeOutlet.placeholder = "Split"
        timeOutlet.isEnabled = false
        
    }
}
