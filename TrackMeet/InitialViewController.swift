//
//  InitialViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/24/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    var allAthletes = [Athlete]()
    var events = [Event]()
    var meets = [Meet]()
    var selectedMeet : Meet?
    var schools = ["Crystal Lake Central": "CLC", "Crystal Lake South": "CLS", "Cary Grove": "CG", "Prairie Ridge": "PR"]
    
    
    func randomizeAthletes(){
        allAthletes.append(Athlete(f: "Owen", l: "Mize", s: "CLC", g: 12))
               allAthletes.append(Athlete(f: "Jakhari", l: "Anderson", s: "CG", g: 12))
               allAthletes.append(Athlete(f: "Drew", l: "McGinness", s: "CLS", g: 9))
        let letters = "abcdefghijklmnopqrstuvwxyz"
        let chars = Array(letters)
        let schoolArray = ["CLC","CG","CLS","PR"]
        
        for _ in 3...75{
            var first = ""
            var last = ""
            for _ in 0...4{
                first.append(String(chars[Int.random(in: 0 ..< chars.count)]))
                last.append(String(chars[Int.random(in: 0 ..< chars.count)]))
            }
            let school = schools.randomElement()?.value
            //let school = schoolArray.randomElement()!
            let grade = Int.random(in: 9...12)
            
            allAthletes.append(Athlete(f: first, l: last, s: school!, g: grade))
            
        }
        var teams = ["A","B","C"]
        var levels = ["VAR", "F/S"]
        for school in schoolArray{
            for letter in teams{
                allAthletes.append(Athlete(f: letter, l: school, s: school, g: 12))
        }
        }
             
        
    }
    
    func sortByName(){
        allAthletes.sort(by: {$0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})
    }
    
    
    
    override func viewDidLoad() {
            super.viewDidLoad()
            randomizeAthletes()
        sortByName()
            

            // Do any additional setup after loading the view.
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddMeetSegue"{
            let nvc = segue.destination as! AddMeetViewController
            nvc.allAthletes = allAthletes
            nvc.schools = schools
        }
    
        
    }

}
