//
//  AddAthleteToEventViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/20/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import UIKit
import Firebase

class AddAthleteToEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBarOutlet: UITabBar!
    var lev = ""
        var screenTitle = ""
       // var allAthletes = [Athlete]()
        var eventAthletes = [Athlete]()
    var heat1 = [Athlete]()
    var heat2 = [Athlete]()
        var displayedAthletes = [Athlete]()
    var meet : Meet!
    var schools = [String]()
        
    
        override func viewDidLoad() {
            super.viewDidLoad()
            self.title = screenTitle
            lev = String(screenTitle.suffix(3))
            for a in AppData.allAthletes{
                if meet.schools.keys.contains(a.schoolFull){
                    displayedAthletes.append(a)
                }
            }
          
             schools = [String](meet.schools.values)
            let tabItems = tabBarOutlet.items!
                 var i = 0
                 for school in schools{
                     tabItems[i].title = school
                     i+=1
                 }
           
        }
    
    override func viewWillDisappear(_ animated: Bool) {
      
     selectAthletes()
        if isMovingFromParent{
               performSegue(withIdentifier: "unwindToEventEdit", sender: self)
              }
    }
        
        override func viewDidAppear(_ animated: Bool) {
            tableView.reloadData()
        }
        

        // MARK: - Table view data source

        func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
            
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return displayedAthletes.count
        }

        
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! AthleteTableViewCell
            let athlete = displayedAthletes[indexPath.row]
        cell.nameOutlet.text = "\(athlete.last), \(athlete.first)"
        cell.schoolOutlet.text = "\(athlete.school)"
        cell.yearOutlet.text = "\(athlete.grade)"
        
            //print(athlete.grade)
            return cell
        }
        
         func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("Did select row at")
            let selectedAthlete = displayedAthletes[indexPath.row]
            if eventAthletes.contains(where: { $0.equals(other: selectedAthlete)}) || heat1.contains(where: { $0.equals(other: selectedAthlete)}) || heat2.contains(where: { $0.equals(other: selectedAthlete)}) {
                let alert = UIAlertController(title: "Error!", message: "Athlete already in event", preferredStyle: .alert)
                let action = UIAlertAction(title: "ok", style: .cancel) { (action) in
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
                alert.addAction(action)
               present(alert, animated: true, completion: nil)
                
            } else {
            
            //print(selectedAthlete.first)
          
            }
        }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if Meet.canManage{return true}
        if let user = Auth.auth().currentUser{
        let sf = displayedAthletes[indexPath.row].schoolFull
        for s in AppData.schoolsNew{
            if s.full == sf{
                for coach in s.coaches{
                    
                    if user.email == coach{
                        return true
                    }
                }
            }
        }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
//            let alert = UIAlertController(title: "Are you sure?", message: "Deleting this athlete will also delete any results stored for this athlete", preferredStyle:    .alert)
//            let ok = UIAlertAction(title: "Delete", style: .destructive) { (a) in
//                let selected = self.displayedAthletes[indexPath.row]
//                AppData.allAthletes.removeAll { (athlete) -> Bool in
//                    athlete.equals(other: selected)
//
//                }
//                selected.deleteFromFirebase()
//                     self.displayedAthletes.remove(at: indexPath.row)
//                            tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//            alert.addAction(cancel)
//            alert.addAction(ok)
//            self.present(alert, animated: true, completion: nil)
//        }
            
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
               
                
                
            let alert = UIAlertController(title: "", message: "Edit Athlete", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textField) in
                    textField.autocapitalizationType = .allCharacters
                    textField.text = self.displayedAthletes[indexPath.row].first
                    
                })
            alert.addTextField(configurationHandler: { (textField) in
                textField.autocapitalizationType = .allCharacters
                textField.text = self.displayedAthletes[indexPath.row].last
                
            })
//            alert.addTextField(configurationHandler: { (textField) in
//                textField.autocapitalizationType = .allCharacters
//                textField.text = self.displayedAthletes[indexPath.row].school
//
//            })
            alert.addTextField(configurationHandler: { (textField) in
                textField.keyboardType = UIKeyboardType.numberPad
                textField.autocapitalizationType = .allCharacters
                textField.text = "\(self.displayedAthletes[indexPath.row].grade)"
                
            })
                alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                  
                    self.displayedAthletes[indexPath.row].first = alert.textFields![0].text!
                    self.displayedAthletes[indexPath.row].last = alert.textFields![1].text!
                   // self.displayedAthletes[indexPath.row].school = alert.textFields![2].text!
                    if let grade = Int(alert.textFields![2].text!){
                        self.displayedAthletes[indexPath.row].grade = grade}
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                    for i in 0 ..< AppData.allAthletes.count{
                       if self.displayedAthletes[indexPath.row].equals(other: AppData.allAthletes[i]){
                        AppData.allAthletes[i].first = alert.textFields![0].text!
                         AppData.allAthletes[i].last = alert.textFields![1].text!
                         //AppData.allAthletes[i].school = alert.textFields![2].text!
                          if let grade = Int(alert.textFields![2].text!){
                                AppData.allAthletes[i].grade = grade}
                        
                        // updateFirebase
                        print(AppData.allAthletes[i].first)
                        AppData.allAthletes[i].updateFirebase()
                        // save changes to userDefaults
                        let userDefaults = UserDefaults.standard
                        do {

                            try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
                               } catch {
                                   print(error.localizedDescription)
                               }
                                              break
                                          }
                    }
                  
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: false)
            }

        

        edit.backgroundColor = UIColor.blue

        return [edit]
    }
    
    func selectAthletes(){
        if let selectedPaths = tableView.indexPathsForSelectedRows{
                 print(selectedPaths)
                 for path in selectedPaths{
                    let selectedAthlete = displayedAthletes[path.row]
                    
                     print("level of selected athletes: \(lev)")
                    selectedAthlete.addEvent(e: Event(name: self.title!, level: lev, meetName: meet.name))
                     eventAthletes.append(selectedAthlete)
                 }
            print("Athletes in the event")
            for ath in eventAthletes{
                for eve in ath.events{
                    print("\(ath.last) \(eve.name)")
                }
            }
             }
    }
        

    @IBAction func addSelectedAction(_ sender: UIButton) {
        //selectAthletes()
        performSegue(withIdentifier: "unwindToEventEdit", sender: self)
    }
    
        func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            selectAthletes()
            displayedAthletes = [Athlete]()
            for a in AppData.allAthletes{
            
                if item.title == a.school{
                    if a.schoolFull.suffix(3) == "(\(meet.gender))"{
                    displayedAthletes.append(a)
                    }
                }
            }
            //self.title = item.title
            
            self.tableView.reloadData()
            
        }
       
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "unwindToEventEdit"{
           // selectAthletes()
        let nvc = segue.destination as! addAthleteViewController
       // nvc.allAthletes = allAthletes
        nvc.eventAthletes = eventAthletes
        nvc.from = screenTitle
        nvc.schools = schools
        nvc.meet = meet
        nvc.lev = lev
        nvc.meetName = meet.name
        }
        
    }

    
    
    }

