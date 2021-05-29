//
//  TimeTableViewCell.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/17/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//


import UIKit
public class TimeTableViewCell : UITableViewCell{
  
    @IBOutlet weak var timeOutlet: UITextField!
    @IBOutlet weak var nameOutlet: UILabel!
  
    @IBOutlet weak var schoolOutlet: UILabel!
    
    @IBOutlet weak var placeOutlet: UITextField!
    
    @IBOutlet weak var pointsOutlet: UILabel!
    
    @IBOutlet weak var gradeOutlet: UILabel!
    
    
    func configure(text: String, placeholder : String, placeText : String){
        if Meet.canManage{
            timeOutlet.isEnabled = true
            placeOutlet.isEnabled = true
        }
        else{
            timeOutlet.isEnabled = false
            placeOutlet.isEnabled = false
        }
        timeOutlet.placeholder = placeholder
        timeOutlet.text = text
        placeOutlet.placeholder = "PL"
        placeOutlet.text = placeText
        pointsOutlet.text = ""
    }
    
    func configure(text: String, placeholder : String, placeText : String, pointsText : String){
        if Meet.canManage{
            timeOutlet.isEnabled = true
            placeOutlet.isEnabled = true
        }
        else{
            timeOutlet.isEnabled = false
            placeOutlet.isEnabled = false
        }
           timeOutlet.placeholder = placeholder
           timeOutlet.text = text
           placeOutlet.placeholder = "PL"
           placeOutlet.text = placeText
        pointsOutlet.text = "\(pointsText) points"
       }
    
    func configure(text: String, placeholder : String){
        if Meet.canManage{
            timeOutlet.isEnabled = true
            placeOutlet.isEnabled = true
        }
        else{
            timeOutlet.isEnabled = false
            placeOutlet.isEnabled = false
        }
           timeOutlet.placeholder = placeholder
           timeOutlet.text = text
           placeOutlet.placeholder = "PL"
        placeOutlet.text = ""
        pointsOutlet.text = ""
          
           
       }
    
}


