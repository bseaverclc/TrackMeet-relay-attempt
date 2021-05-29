//
//  addAthleteViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/18/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import UIKit

class addAthleteViewController: UIViewController {
    var meet : Meet!
    var athlete : Athlete!
    //var allAthletes = [Athlete]()
    var displayedAthletes = [Athlete]()
    var eventAthletes = [Athlete]()
    var from = ""
    var lev = ""
    var meetName = ""
    var schools = [String]()
  
    @IBOutlet weak var schoolOutlet: UISegmentedControl!
    @IBOutlet weak var yearOutlet: UISegmentedControl!
    @IBOutlet weak var lastOutlet: UITextField!
    @IBOutlet weak var firstOutlet: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        schoolOutlet.removeAllSegments()
        for (_,initials) in meet.schools{
        schoolOutlet.insertSegment(withTitle: initials, at: 0, animated: true)
    }
    }
    
    func sameAthleteError()-> Bool{
        let alert =  UIAlertController(title: "Error", message: "Athlete already exists in database", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(alertaction) in
            print("Hit OK")
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        return false
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        
        var addAthlete = true
        if schoolOutlet.selectedSegmentIndex >= 0 {
        
        let first = firstOutlet.text
            let last = lastOutlet.text
            let school = schoolOutlet.titleForSegment(at: schoolOutlet.selectedSegmentIndex)
            let year = yearOutlet.titleForSegment(at: yearOutlet.selectedSegmentIndex)
            var schoolFull = ""
            for (full,initials) in meet.schools{
                if school == initials{
                    schoolFull = full
                    break
                }
            }
        
            if schoolFull == ""{
                schoolFull = schools[0]
            }
           
            athlete = Athlete(f: first!, l: last!, s: school!, g: Int(year!)!, sf: schoolFull)
            
            for a in AppData.allAthletes{
                if a.equals(other: athlete){
                   resignFirstResponder()
                   addAthlete = sameAthleteError()
                   
                    break
                }
            }
            if addAthlete{
            print("Created Athlete")
            AppData.allAthletes.insert(athlete, at: 0)
            
                // Save
                let userDefaults = UserDefaults.standard
                do {
                    try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
                       } catch {
                           print(error.localizedDescription)
                       }
                
            if from == "AthletesVC"{
            displayedAthletes.insert(athlete, at: 0)
                print(athlete.schoolFull)
            performSegue(withIdentifier: "unwindToRosters", sender: self)
            }
            else{
                athlete.events.append(Event(name: from, level: lev, meetName: meetName ))
                eventAthletes.append(athlete)
                performSegue(withIdentifier: "unwindToRosters", sender: self)
            }
                athlete.saveToFirebase()
            }
        }
        else{
            let alert2 = UIAlertController(title: "Error!", message: "You must pick a school", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert2.addAction(action)
            present(alert2, animated: true, completion: nil)
        }
        
    }
    

    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
