//
//  ScoresViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/21/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import UIKit

class ScoresViewController: UIViewController {
    //var allAthletes: [Athlete]!
    @IBOutlet weak var textViewOutlet: UITextView!
    
    @IBOutlet weak var copyButton: UIButton!
    
    var relayString = ""
    var teamPoints = [String: [String:Double]]()
    var fieldEvents = ["Long Jump", "Triple Jump", "High Jump", "Pole Vault", "Shot Put", "Discus"]
   
    var meet : Meet!
    var levels = [String]()
    
    var schoolsOutlet = [UILabel]()
    
    @IBOutlet weak var meetNameOutlet: UILabel!
    @IBOutlet var levelsOutlet: [UILabel]!
    @IBOutlet var schoolsStackView: [UIStackView]!
    @IBOutlet var scoresStackView: [UIStackView]!
    
    @IBOutlet weak var CLCFSOutlet: UILabel!
    @IBOutlet weak var CLSFSOutlet: UILabel!
    @IBOutlet weak var CGFSOutlet: UILabel!
    @IBOutlet weak var PRFSOutlet: UILabel!
    
    
    @IBOutlet weak var PRScoreOutlet: UILabel!
    @IBOutlet weak var CLSScoreOutlet: UILabel!
    @IBOutlet weak var CLCScoreOutlet: UILabel!
    @IBOutlet weak var CGScoreOutlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewOutlet.isEditable = false
        copyButton.titleLabel?.numberOfLines = 2
        copyButton.setTitle("Copy results and\ngo to athletic.net", for: .normal)
        meetNameOutlet.text = meet.name
        print("meet name : \(meet.name)")
   
        var initials = [String](meet.schools.values)
        for i in 0 ..< initials.count{
            initials[i] = initials[i].uppercased()
        }
        initials.sort(by: {$0 < $1 })
        levels = meet.levels
        for lev in levels{
            // hard code the first one
            teamPoints[lev] = [initials[0]: 0.0]
            // fill in the rest if needed
            for i in 1..<initials.count{
                    (teamPoints[lev]!)[initials[i]] = 0.0
                }
           
            }
        
        print("initial team points: \(teamPoints)")
        computeScores()
        print("Scores View Did Load")
    }
    

    func computeScores(){
        
        for a in AppData.allAthletes{
            //var updated = false
            
            for e in a.events{
                if e.meetName == meet.name{
                    if e.markString != "" {
                        print("There is a mark or a place")
                        var units = ""
                        if e.name.contains("Jump") || e.name.contains("Vault") || e.name.contains("Shot") || e.name.contains("Discus"){
                            units = "m"
                        }
                    //var current = teamPoints[e.level]!
                        
                        if let currentPoints = teamPoints[e.level]?[a.school]{
                        teamPoints[e.level]!.updateValue(currentPoints + e.points, forKey: a.school)
                        print("points added to school \(a.school): \(teamPoints[e.level]![a.school] ?? 0.0)")
                        }
                        
                     
                    
                    // if event was a relay
                    if e.name.contains("4x"){
                        relayString = ""
                        if let relayMembers = e.relayMembers{
                            for id in relayMembers{
                                for ath in AppData.allAthletes{
                                    if ath.uid == id{
                                        relayString = "\(relayString),\(ath.last),\(ath.first),\(ath.grade)"
                                        break;
                                    }
                                }
                            
                            }
                            
                            
                        }
                        // if they placed put place in output
                       if let pl = e.place{
                        textViewOutlet.text += "R,\(meet.gender),\(e.level),\(e.name.dropLast(4)),\(pl),,,,\(a.schoolFull),\(e.markString)\(units),\(e.points),Finals,,\(relayString)\n"
                                          }
                        // if they didn't place leave spot open
                       else{
                        textViewOutlet.text += "R,\(meet.gender),\(e.level),\(e.name.dropLast(4)),,,,,\(a.schoolFull),\(e.markString)\(units),\(e.points),Finals,,\(relayString)\n"
                            }
                    }
                      //  If event was individual
                    else{
                      if let pl = e.place{
                        textViewOutlet.text += "E,\(meet.gender),\(e.level),\(e.name.dropLast(4)),\(pl),\(a.last),\(a.first) ,\(a.grade),\(a.schoolFull),\(e.markString)\(units),\(e.points),Finals, , \n"
                      }
                      else{
                        textViewOutlet.text += "E,\(meet.gender),\(e.level),\(e.name.dropLast(4)), ,\(a.last),\(a.first) ,\(a.grade),\(a.schoolFull),\(e.markString)\(units),\(e.points),Finals, , \n"
                        
                        }
                        }
                   
                    
                }
                }
            }
                }
        
            
       // Need to figure out how to clear out labels everytime????
        // I think I should add the labels in view did load and update their text values here
        // I will need to build an array of uiLabels
            var i = 0
        let sortedTeamPoints = teamPoints.sorted{ $0.key < $1.key }
        for (level,scores) in sortedTeamPoints {
            if i < schoolsStackView.count{
            // add level text header
            levelsOutlet[i].text = "\(level) Scores"
        
                
                let sortedScores = scores.sorted{ $0.key < $1.key }
            for (initials,score) in sortedScores{
                // print info to textview
                var fullSchool = ""
                for (sch,ini) in meet.schools{
                    if initials == ini{
                        fullSchool = sch
                    }
                }
            textViewOutlet.text += "S,\(meet.gender),\(level),,\(fullSchool),\(score)\n"
                
                // set up school labels
                let label = UILabel()
                label.text = "\(initials)"
                label.textAlignment = .center
                schoolsStackView[i].addArrangedSubview(label)
                
                // set up score labels
                let label2 = UILabel()
                label2.text = "\(score)"
                label2.textAlignment = .center
                scoresStackView[i].addArrangedSubview(label2)
                }
                
            }
            else{print("i value too big when adding score labels")}
            i+=1
        }
        

    }
        

    @IBAction func copyAction(_ sender: UIButton) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = textViewOutlet.text
        if let url = URL(string: "https://www.athletic.net/TrackAndField/Illinois/") {
                   UIApplication.shared.open(url)
               }
    }
}
