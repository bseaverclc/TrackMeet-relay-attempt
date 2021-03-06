//
//  RelayViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/15/21.
//  Copyright © 2021 clc.seaver. All rights reserved.
//
// now working
// testing if syncs with github

import UIKit

class RelayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var AthleteTableView: UITableView!
    @IBOutlet weak var relayTableView: UITableView!
    
    
    
    var runners = [Athlete]()
    var schoolAthletes = [Athlete]()
    var theSchool : String!
    var meet: Meet!
    var screenTitle = ""
    var lev = ""
    var theRelay : Athlete!
    var theEvent : Event!
    var titleSplit = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "\(screenTitle) \(theRelay.last),\(theRelay.first) splits"
        
        let start = screenTitle.index(screenTitle.startIndex, offsetBy: 2)
        let end = screenTitle.index(screenTitle.startIndex, offsetBy:   4)
        let range = start...end
        titleSplit = "\(screenTitle[range]) split \(lev)"
        
        AthleteTableView.delegate = self
        AthleteTableView.dataSource = self
        relayTableView.delegate = self
        relayTableView.dataSource = self

        for a in AppData.allAthletes{
            if a.schoolFull == theSchool{
                schoolAthletes.append(a)
            }
        }
        
//        if let members = theEvent.relayMembers{
//            for id in members{
//                for ath in AppData.allAthletes{
//                    if ath.uid == id{
//                        runners.append(ath)
//                        break;
//                    }
//                }
//
//            }
//
//       }
        
        
      
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("RelayVC viewWillAppear")
        runners.removeAll();
        if let members = theEvent.relayMembers{
            for id in members{
                for ath in AppData.allAthletes{
                    if ath.uid == id{
                        runners.append(ath)
                        break;
                    }
                }
            
            }
        
       }
    }
    
    func canEdit()->Bool{
        return Meet.canManage || theRelay.schoolFull == AppData.mySchool
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        print("tapping")
        view.endEditing(true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == relayTableView{
            return 4
        }
        else{
            return schoolAthletes.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == relayTableView{
            return "Relay Members"
        }
        else{
            return "Roster"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == relayTableView{
            print("relayTableView Adding")
            let cell = tableView.dequeueReusableCell(withIdentifier: "relayCell") as! RelayTableViewCell
            cell.configure()
            if indexPath.row < runners.count{
            for event in runners[indexPath.row].events{
                  
                if event.name == titleSplit && event.meetName == meet.name {
                    cell.configure(ath: runners[indexPath.row], ev: event, editable: canEdit())
                    //cell.timeOutlet.tag = indexPath.row
                    break;
                }
                
                
            }
            }
            
            return cell
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "athleteCell")!
            cell.textLabel?.text = "\(schoolAthletes[indexPath.row].last), \(schoolAthletes[indexPath.row].first)"
            cell.detailTextLabel!.text = "\(schoolAthletes[indexPath.row].grade)"
            return cell
        }
    }
    

   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select row at")
        if Meet.canCoach{
                       
        if tableView == AthleteTableView{
            if !Meet.canManage && theRelay.schoolFull != AppData.mySchool{
                           return
            }
            if runners.count < 4{
            runners.append(schoolAthletes[indexPath.row])
            
            schoolAthletes[indexPath.row].addEvent(e: Event(name: titleSplit, level: lev, meetName: meet.name))
            if let members = theEvent.relayMembers{
                
            }
            else{
                theEvent.relayMembers = [String]()
            }
            theEvent.relayMembers?.append(schoolAthletes[indexPath.row].uid!)
            theRelay.updateFirebase()
            relayTableView.reloadData()
            //tableView.reloadData()
            print("Added relay athlete")
        }
        }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (tableView == relayTableView && (Meet.canManage || theRelay.schoolFull == AppData.mySchool)){ return true}
        else{ return false}
    
       
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == relayTableView{
            if editingStyle == .delete && indexPath.row < runners.count{
                theEvent.relayMembers?.remove(at: indexPath.row)
                theRelay.updateFirebase()
                
                for event in runners[indexPath.row].events{
                      
                    if event.name == titleSplit && event.meetName == meet.name{
                        if let euid = event.uid{
                            print("calling deleteEventFromFirebase")
                        runners[indexPath.row].deleteEventFromFirebase(euid: euid)
                        //cell.timeOutlet.tag = indexPath.row
                        break;
                    }
                }
                
                
            }
                runners.remove(at: indexPath.row)
                relayTableView.reloadData()
        }
    }
    
    }
    
    
    
    @IBAction func timeAction(_ sender: UITextField) {
        print("Time action happening")
        if Meet.canCoach{
            
            
            guard let cell2 = sender.findParentTableViewCell (),
                let indexPath2 = relayTableView.indexPath(for: cell2) else {
                    print("This textfield is not in the tableview!")
                    return
            }
            if indexPath2.row < runners.count{
            if let mark = sender.text{
                for event in runners[indexPath2.row].events{
                    if event.name == titleSplit && event.meetName == meet.name{
                       
                            event.markString = mark
                            print("no sections set mark")
                     runners[indexPath2.row].updateFirebase()
                                 }
                             }
                 }
        }
        
            }
            
        }
    
}
