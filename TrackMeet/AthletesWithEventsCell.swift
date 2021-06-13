//
//  AthletesWithEventsCell.swift
//  TrackMeet
//
//  Created by Brian Seaver on 6/12/21.
//  Copyright © 2021 clc.seaver. All rights reserved.
//

import UIKit

public class AthletesWithEventsCell : UITableViewCell{
    
    
    @IBOutlet weak var NameOutlet: UILabel!
    

    
    
    @IBOutlet var eventsOutlet: [UILabel]!
    func configure(ath:Athlete, meet: Meet){
        for outlet in eventsOutlet{
            outlet.text = ""
        }
        NameOutlet.backgroundColor = .clear
        
        NameOutlet.text = "\(ath.last), \(ath.first) (\(ath.grade))"
        var count = 0
        for ev in ath.events{
            if ev.meetName == meet.name{
                if count < 4{
                eventsOutlet[count].text = ev.name
                    NameOutlet.backgroundColor = .green
                count = count + 1
                }
                else{
                    NameOutlet.backgroundColor = UIColor.red
                }
            }
        }
        
        
    }
    
    func configure(ath:Athlete){
        NameOutlet.text = "\(ath.last), \(ath.first) (\(ath.grade))"
       
        for outlet in eventsOutlet{
            outlet.text = ""
        }
       
    }
    
}

