//
//  ViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/17/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import UIKit
import Firebase

extension UIResponder {
    func findParentTableViewCell () -> UITableViewCell? {
        var parent: UIResponder = self
        while let next = parent.next {
            if let tableViewCell = parent as? UITableViewCell {
                return tableViewCell
            }
            parent = next
        }
        return nil
    }
}

extension UITableView {
    // allow to move tableview up when keyboard shows
    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)

        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
}

class EventEditViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UINavigationControllerDelegate, UITabBarDelegate {
    
    @IBOutlet weak var processOutlet: UIButton!
    
    @IBOutlet weak var addButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var clearPlaceOutlet: UIButton!
    
    @IBOutlet weak var refreshOutlet: UIButton!
    var selectedRow : Int!
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    var tabBarY : CGFloat!
    var fieldEvents = ["Long Jump", "Triple Jump", "High Jump", "Pole Vault", "Shot Put", "Discus"]
    var fieldEventsLev = [String]()
    var meet : Meet!
    var sections = false
    //var allAthletes = [Athlete]()
    var eventAthletes = [Athlete]()
    var heat1 = [Athlete]()
    var heat2 = [Athlete]()
    var screenTitle = ""
    var selectedSchool = ""
    var selectedRelay : Athlete!
    var selectedEvent : Event!
    
    @IBOutlet weak var tabBarOutlet: UITabBar!
    
    @objc func keyboardWillShow(notification: Notification){
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
               print("Notification: Keyboard will show")
            tableViewOutlet.setBottomInset(to: keyboardHeight + tabBarOutlet.frame.height)
            
            tabBarOutlet.frame.origin.y = tabBarY - keyboardHeight
    }
    }
    
    @objc func keyboardWillHide(notification: Notification){
        print("Notification: Keyboard will hide")
        tabBarOutlet.frame.origin.y = tabBarY
        tableViewOutlet.setBottomInset(to: tabBarOutlet.frame.height)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
             NotificationCenter.default.addObserver(self, selector: #selector(EventEditViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
           
                    NotificationCenter.default.addObserver(self, selector: #selector(EventEditViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if (self.title!.contains("100M")  || (self.title!.contains("200M") && !(self.title!.contains("3200M"))) || self.title!.contains("400M")) {
                tableViewOutlet.isEditing = true
               sections = true
           }
        tableViewOutlet.setBottomInset(to: tabBarOutlet.frame.height)
       }
       
       override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
        print("editEvent is disappearing")
        

       
           if isMovingFromParent{
           performSegue(withIdentifier: "unwindToEventsSegue", sender: self)
           }

              NotificationCenter.default.removeObserver(self)
           tabBarOutlet.frame.origin.y = tabBarY
       }
       
       override func viewDidAppear(_ animated: Bool) {
           tabBarY = tabBarOutlet.frame.origin.y
        if Meet.canCoach{
            addButtonOutlet.isEnabled = true
        }
        else{
            addButtonOutlet.isEnabled = false
        }
        
        if meet.beenScored[selectedRow]{
             processOutlet.setTitle("Processed", for: .normal)
            processOutlet.backgroundColor = UIColor.green
        }
        else{
            processOutlet.setTitle("Process Event", for: .normal)
            processOutlet.backgroundColor = UIColor.lightGray
        }
       }
    
    func scaleStuff(){
        clearPlaceOutlet.titleLabel?.minimumScaleFactor = 0.5
       clearPlaceOutlet.titleLabel?.numberOfLines = 1
        clearPlaceOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
        
        processOutlet.titleLabel?.minimumScaleFactor = 0.5
        processOutlet.titleLabel?.numberOfLines = 1
        processOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
        
       refreshOutlet.titleLabel?.minimumScaleFactor = 0.5
        refreshOutlet.titleLabel?.numberOfLines = 1
        refreshOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
        
        if !Meet.canManage{
            clearPlaceOutlet.isHidden = true
            processOutlet.isEnabled = false;
        }
    }
       
       override func viewDidLoad() {
           super.viewDidLoad()
        scaleStuff()
        eventAthletes = [Athlete]()
        heat1 = [Athlete]()
        heat2 = [Athlete]()
          
          
           
           let fontAttributes2 = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title3)]
           UITabBarItem.appearance().setTitleTextAttributes(fontAttributes2, for: .normal)
        
           for lev in meet.levels{
           for event in fieldEvents{
               fieldEventsLev.append("\(event) \(lev)")
               }
           }
           
           self.title = screenTitle
           for a in AppData.allAthletes{
                     for e in a.events{
                       if e.name == screenTitle && e.meetName == meet.name{
                           switch e.heat{
                           //case 0: eventAthletes.append(a)
                           case 1: heat1.append(a)
                           case 2: heat2.append(a)
                           default: eventAthletes.append(a)
                           }
                             
                         }
                     }
                 }
           if meet.beenScored[selectedRow]{
                processOutlet.setTitle("Processed", for: .normal)
               processOutlet.backgroundColor = UIColor.green
               calcPoints()
           }
           else{
               processOutlet.setTitle("Process Event", for: .normal)
               processOutlet.backgroundColor = UIColor.lightGray
           }
           
           sortByMark()
           sortByPlace()
           tableViewOutlet.reloadData()
           print("eventEditVDL")
    
         
           // Do any additional setup after loading the view.
       }
    
    // tableview functions
    func numberOfSections(in tableView: UITableView) -> Int {
        if sections{return 3}
        else{ return 1}
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections{
        if section == 0{return "Heat 1"}
        else if section == 1{return "Heat 2"}
        else{ return "Open"}
        }
        else{return self.title}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections{
        if section == 0{return heat1.count}
        else if section == 1 {return heat2.count}
        else{ return eventAthletes.count}
        }
        
        else{return eventAthletes.count}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           // customized cell
           let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! TimeTableViewCell
         
          
           
           var currentAthletes = [Athlete]()
           if !sections{ currentAthletes = eventAthletes}
           else{ if indexPath.section == 0 {currentAthletes = heat1}
           else if indexPath.section == 1 {currentAthletes = heat2}
           else {currentAthletes = eventAthletes}
           }
           
           for event in currentAthletes[indexPath.row].events{
            
               if event.name == title  && event.meetName == meet.name{
                   if let place = event.place{
                    if !meet.beenScored[selectedRow]{
                   cell.configure(text: event.markString, placeholder: "Mark", placeText: "\(place)")
                   }
                    else{
                        cell.configure(text: event.markString, placeholder: "Mark", placeText: "\(place)", pointsText: String(event.points))
                    }
                   }
                   else{
                       cell.configure(text: event.markString, placeholder: "Mark")
                       
                   }
               }
           }
           
           let athlete = currentAthletes[indexPath.row]
           cell.nameOutlet.text = "\(athlete.last), \(athlete.first)"
           cell.schoolOutlet.text = athlete.school
           cell.timeOutlet.tag = indexPath.row
           cell.placeOutlet.tag = indexPath.row
           cell.gradeOutlet.text = "\(athlete.grade)"
           return cell
       }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if Meet.canManage{return true}
        if sections{
            switch indexPath.section{
            case 0:
                if heat1[indexPath.row].schoolFull != AppData.mySchool{
                    return false
                }
            case 1:
                if heat2[indexPath.row].schoolFull != AppData.mySchool{
                    return false
                }
            default:
                if eventAthletes[indexPath.row].schoolFull != AppData.mySchool{
                    return false
                }
            }
        }
        else{
            if eventAthletes[indexPath.row].schoolFull != AppData.mySchool{
                return false
            }
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if Meet.canCoach{
        meet.beenScored[selectedRow] = false
        meet.updatebeenScoredFirebase()
        processOutlet.backgroundColor = UIColor.lightGray
        processOutlet.setTitle("Process Event", for: .normal)
        
        var movingAthlete: Athlete!
        if sections{
         if (sourceIndexPath != destinationIndexPath ) {
            let sectionFrom = sourceIndexPath.section
            let sectionTo = destinationIndexPath.section
           
            if sectionFrom == 0{
                movingAthlete = heat1[sourceIndexPath.row]
                heat1.remove(at: sourceIndexPath.row)
            }
            else if sectionFrom == 1 {
                movingAthlete = heat2[sourceIndexPath.row]
                heat2.remove(at: sourceIndexPath.row)
            }
            else{
                movingAthlete = eventAthletes[sourceIndexPath.row]
                eventAthletes.remove(at: sourceIndexPath.row)
            }
            
            if sectionTo == 0 {
                heat1.insert(movingAthlete, at: destinationIndexPath.row)
                movingAthlete.getEvent(eventName: screenTitle, meetName: meet.name)?.heat = 1
                
            }
            else if sectionTo == 1 {
                heat2.insert(movingAthlete, at: destinationIndexPath.row)
                movingAthlete.getEvent(eventName: screenTitle, meetName: meet.name
                    )?.heat = 2
            }
            
            else if sectionTo == 2 {eventAthletes.insert(movingAthlete, at: destinationIndexPath.row)
                movingAthlete.getEvent(eventName: screenTitle, meetName: meet.name)?.heat = 0
            }
            }
            
            
        }
        else{
            movingAthlete = eventAthletes[sourceIndexPath.row]
            eventAthletes.remove(at: sourceIndexPath.row)
            eventAthletes.insert(movingAthlete, at: destinationIndexPath.row)
            
        }
        if movingAthlete != nil{
        movingAthlete.updateFirebase()
        }
        tableView.reloadData()

        }
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if(screenTitle.contains("4x")){
//            if !Meet.canManage && eventAthletes[indexPath.row].schoolFull != AppData.mySchool{
//                return
//            }
            selectedSchool = eventAthletes[indexPath.row].schoolFull
            selectedRelay = eventAthletes[indexPath.row]
            for e in selectedRelay.events{
                if e.name == screenTitle && e.meetName == meet.name{
                    selectedEvent = e
                }
            }
            performSegue(withIdentifier: "relaySegue", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//Coaches can edit all athletes
        if Meet.canCoach{
            return true
        }
        else{
            return false
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if Meet.canCoach{
        if editingStyle == .delete{
            
            
            
            meet.beenScored[selectedRow] = false
            meet.updatebeenScoredFirebase()
            processOutlet.backgroundColor = UIColor.lightGray
            processOutlet.setTitle("Process Event", for: .normal)
            if sections{
                let sec = indexPath.section
            
            switch sec{
            case 0:
                var canDelete = AppData.mySchool == heat1[indexPath.row].schoolFull
                if Meet.canManage{
                    canDelete = true;
                }
                
                for e in heat1[indexPath.row].events{
                    if e.name == self.title && e.meetName == self.meet.name{
                        if e.markString != "" || e.place != nil{
                            canDelete = false
                        }
                    }
                    
                }
                
                if canDelete{
                
                heat1[indexPath.row].events.removeAll { (e) -> Bool in
                    print(e.uid ?? "No uid?")
                    if e.name == self.title && e.meetName == self.meet.name {
                        if let euid = e.uid{
                            print("calling deleteEventFromFirebase")
                            
                        heat1[indexPath.row].deleteEventFromFirebase(euid: euid)
                       
                        }
                        return true
                    }
                    return false
                }
                heat1.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                    
                }
                
            case 1:
                var canDelete = AppData.mySchool == heat2[indexPath.row].schoolFull
                if Meet.canManage{
                    canDelete = true;
                }
                for e in heat2[indexPath.row].events{
                    if e.name == self.title && e.meetName == self.meet.name{
                        if e.markString != "" || e.place != nil{
                            canDelete = false
                        }
                    }
                    
                }
                
                if canDelete{
                
                heat2[indexPath.row].events.removeAll { (e) -> Bool in
                    print(e.uid ?? "No UID?")
                    if e.name == self.title && e.meetName == self.meet.name {
                        if let euid = e.uid{
                            print("calling deleteEventFromFirebase")
                        heat2[indexPath.row].deleteEventFromFirebase(euid: euid)
                       
                        }
                        return true
                    }
                    return false
                }
                heat2.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                }
                
            default:
                var canDelete = AppData.mySchool == eventAthletes[indexPath.row].schoolFull
                if Meet.canManage{
                    canDelete = true;
                }
                for e in eventAthletes[indexPath.row].events{
                    if e.name == self.title && e.meetName == self.meet.name{
                        if e.markString != "" || e.place != nil{
                            canDelete = false
                        }
                    }
                    
                }
                
                if canDelete{
                
                eventAthletes[indexPath.row].events.removeAll { (e) -> Bool in
                    print(e.uid ?? "No UID?")
                    if e.name == self.title && e.meetName == self.meet.name {
                        if let euid = e.uid{
                            print("calling deleteEventFromFirebase")
                        eventAthletes[indexPath.row].deleteEventFromFirebase(euid: euid)
                       
                        }
                        return true
                    }
                    return false
                }
                eventAthletes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            }
            else{
                var canDelete = AppData.mySchool == eventAthletes[indexPath.row].schoolFull
                if Meet.canManage{
                    canDelete = true;
                }
                for e in eventAthletes[indexPath.row].events{
                    if e.name == self.title && e.meetName == self.meet.name{
                        if e.markString != "" || e.place != nil{
                            canDelete = false
                        }
                    }
                    
                }
                
                if canDelete{
                
                eventAthletes[indexPath.row].events.removeAll { (e) -> Bool in
                    print(e.uid ?? "No UID?")
                    if e.name == self.title && e.meetName == self.meet.name {
                        if let euid = e.uid{
                            print("calling deleteEventFromFirebase")
                            deleteRelayMembers(ev: e)
                        eventAthletes[indexPath.row].deleteEventFromFirebase(euid: euid)
                       
                        }
                        return true
                    }
                    return false
                }
                               eventAthletes.remove(at: indexPath.row)
                               tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }

            
        }
    }
    }
  
    func deleteRelayMembers(ev: Event){
        if let members = ev.relayMembers{
            let start = ev.name.index(ev.name.startIndex, offsetBy: 2)
            let end = ev.name.index(ev.name.startIndex, offsetBy:   4)
            let range = start...end
            let titleSplit = "\(ev.name[range]) split \(ev.level)"
            
            for id in members{
                for ath in AppData.allAthletes{
                    if ath.uid == id{
                        for e in ath.events{
                            if e.meetName == meet.name && e.name == titleSplit{
                                if let euid = e.uid{
                                ath.deleteEventFromFirebase(euid: euid)
                                print("deleted relay member ")
                                }
                            }
                        }
                        break
                    }
                }
            
            }
        
       }
    }
    
    // Actions
    @IBAction func timeAction(_ sender: UITextField) {
         //print(sender.tag)
        // print(sender.text)
//         var indexPath = IndexPath(row: sender.tag, section: 0)
//         var cell = tableViewOutlet.cellForRow(at: indexPath) as! TimeTableViewCell
        if Meet.canManage{
        print("time action happening")
        
        meet.beenScored[selectedRow] = false
        meet.updatebeenScoredFirebase()
        processOutlet.backgroundColor = UIColor.lightGray
        processOutlet.setTitle("Process Event", for: .normal)
        
        // var editingArray : [Athlete]!
         guard let cell2 = sender.findParentTableViewCell (),
             let indexPath2 = tableViewOutlet.indexPath(for: cell2) else {
                 print("This textfield is not in the tableview!")
                 return
         }
        if let mark = sender.text{
        
       if sections{
               if indexPath2.section == 0{
                   for event in heat1[indexPath2.row].events{
                    if event.name == title && event.meetName == meet.name{
                            
                           event.markString = mark
                           print("section 0 set mark")
                        heat1[indexPath2.row].updateFirebase()
                            
                        }
                    }
                   
               }
               else if indexPath2.section == 1{
                   for event in heat2[indexPath2.row].events{
                        if event.name == title && event.meetName == meet.name{
                            
                   event.markString = mark
                            print("section 1 set mark")
                            heat2[indexPath2.row].updateFirebase()
                            
                        }
                    }
               }
               else{
                   for event in eventAthletes[indexPath2.row].events{
                        if event.name == title && event.meetName == meet.name{
                           
                   event.markString = mark
                            print("sections but no section set mark")
                            eventAthletes[indexPath2.row].updateFirebase()
                            
                        }
                    }
                   
               }
           }
       else{
           for event in eventAthletes[indexPath2.row].events{
               if event.name == title && event.meetName == meet.name{
                  
                       event.markString = mark
                       print("no sections set mark")
                eventAthletes[indexPath2.row].updateFirebase()
                            }
                        }
            }
                       
                   
       }
       
     }
    }
    
    @IBAction func placeAction(_ sender: UITextField) {
        if Meet.canManage{
        meet.beenScored[selectedRow] = false
        meet.updatebeenScoredFirebase()
        processOutlet.backgroundColor = UIColor.lightGray
        processOutlet.setTitle("Process Event", for: .normal)
        //var editingArray : [Athlete]!
        print(sender.tag)
        guard let cell2 = sender.findParentTableViewCell (),
            let indexPath2 = tableViewOutlet.indexPath(for: cell2) else {
                print("This textfield is not in the tableview!")
                return
        }
        //print("The indexPath is \(indexPath2)")
      
                //var indexPath = IndexPath(row: sender.tag, section: 0)
            let place = sender.text!
            
        if sections{
            if indexPath2.section == 0{
                for event in heat1[indexPath2.row].events{
                     if event.name == title && event.meetName == meet.name{
                         if let intPlace = Int(place){
                             event.place = intPlace
                         }
                         else{
                            sender.text = ""
                            event.place = nil}
                        heat1[indexPath2.row].updateFirebase()
                     }
                 }
                
            }
            else if indexPath2.section == 1{
                for event in heat2[indexPath2.row].events{
                     if event.name == title && event.meetName == meet.name{
                         if let intPlace = Int(place){
                event.place = intPlace
                         }
                        else{
                        sender.text = ""
                        event.place = nil}
                        heat2[indexPath2.row].updateFirebase()
                     }
                 }
            }
            else{
                for event in eventAthletes[indexPath2.row].events{
                     if event.name == title && event.meetName == meet.name{
                         if let intPlace = Int(place){
                event.place = intPlace
                         }
                        else{
                        sender.text = ""
                        event.place = nil}
                        eventAthletes[indexPath2.row].updateFirebase()
                     }
                 }
                
            }
        }
        else{
        for event in eventAthletes[indexPath2.row].events{
            if event.name == title && event.meetName == meet.name{
                if let intPlace = Int(place){
                    event.place = intPlace
                             }
                else{
                sender.text = ""
                event.place = nil}
                eventAthletes[indexPath2.row].updateFirebase()
                         }
                     }
            }
                    
                
     }
    }
    
    @IBAction func processEventAction(_ sender: UIButton) {
        if Meet.canManage{
           processOutlet.backgroundColor = UIColor.green
           processOutlet.setTitle("Processed", for: .normal)
        meet.beenScored[selectedRow] = true
        meet.updatebeenScoredFirebase()
           calcPoints()
           // save to userdefaults
        
              let userDefaults = UserDefaults.standard
              do {
                      try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
                     } catch {
                         print(error.localizedDescription)
                     }
       // save to firebase
        for a in eventAthletes{
            a.updateFirebase()
        }
        for a in heat1{
            a.updateFirebase()
        }
        for a in heat2{
            a.updateFirebase()
        }
        }
       }
    
    func clearOutPlaces(){
        if Meet.canManage{
        for a in eventAthletes{
            for e in a.events{
                if e.name == title  && e.meetName == meet.name{
                    e.place = nil
                    a.updateFirebase()
                }
                    
            }
        }
            meet.beenScored[selectedRow] = false
            meet.updatebeenScoredFirebase()
            processOutlet.backgroundColor = UIColor.lightGray
            processOutlet.setTitle("Process Event", for: .normal)
            calcPoints()
        tableViewOutlet.reloadData()
            
        }
    }
    
    @IBAction func clearPlacesAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Caution", message: "Are you sure you want to clear all places?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
            self.clearOutPlaces()
        }))
        present(alert, animated: true, completion: nil)
        
    }
        
    @IBAction func refreshAction(_ sender: UIButton) {
        viewDidLoad()
    }
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    @IBAction func switchAction2(_ sender: UIButton) {
        print("switch action happening")
        let start = screenTitle.index(screenTitle.startIndex, offsetBy: 0)
        let end = screenTitle.index(screenTitle.endIndex, offsetBy: -3)
        let range = start..<end
         
        let check = screenTitle[range]
        for e in meet.events{
            if e != screenTitle && e.contains(check){
                print(e)
                screenTitle = e
                viewDidLoad()
                break
            }
        }
        
    }
    
    
    @IBAction func switchAction(_ sender: UIBarButtonItem) {
        
    }
    
   
  // Sorting Functions
    func sortBySchool(){
        eventAthletes = eventAthletes.sorted { (struct1, struct2) -> Bool in
                        if (struct1.school.lowercased() != struct2.school.lowercased()) { // if it's not the same section sort by section
                            return struct1.school < struct2.school
                        } else { // if it the same section sort by order.
                            return struct1.last.lowercased() < struct2.last.lowercased()
                        }
                    }
        heat1 = heat1.sorted { (struct1, struct2) -> Bool in
            if (struct1.school.lowercased() != struct2.school.lowercased()) { // if it's not the same section sort by section
                return struct1.school < struct2.school
            } else { // if it the same section sort by order.
                return struct1.last.lowercased() < struct2.last.lowercased()
            }
        }
        heat2 = heat2.sorted { (struct1, struct2) -> Bool in
            if (struct1.school.lowercased() != struct2.school.lowercased()) { // if it's not the same section sort by section
                return struct1.school < struct2.school
            } else { // if it the same section sort by order.
                return struct1.last.lowercased() < struct2.last.lowercased()
            }
        }
                    print("Done sorting by school")
                    
                   
                    
        //            eventAthletes.sort(by: {$0.school.localizedCaseInsensitiveCompare($1.school) == .orderedAscending && $0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})
        
    }
    
    func sortByName(){
        eventAthletes = eventAthletes.sorted(by: {$0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})
        heat1 = heat1.sorted(by: {$0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})
                 
        heat2 = heat2.sorted(by: {$0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})
        print("sorting by name")
    }
    
    func sortByPlace(){
        eventAthletes = eventAthletes.sorted { (lhs, rhs) -> Bool in
            let a = lhs.getEvent(eventName: self.title!, meetName: meet.name
                )?.place
            let b = rhs.getEvent(eventName: self.title!, meetName: meet.name)?.place
                     switch (a ,b) {
                       case let(a?, b?): return a < b // Both lhs and rhs are not nil
                       case (nil, _): return false    // Lhs is nil
                       case (_?, nil): return true    // Lhs is not nil, rhs is nil
                       }
                   }
        heat1 = heat1.sorted { (lhs, rhs) -> Bool in
        let a = lhs.getEvent(eventName: self.title!, meetName: meet.name
            )?.place
        let b = rhs.getEvent(eventName: self.title!, meetName: meet.name)?.place
                 switch (a ,b) {
                   case let(a?, b?): return a < b // Both lhs and rhs are not nil
                   case (nil, _): return false    // Lhs is nil
                   case (_?, nil): return true    // Lhs is not nil, rhs is nil
                   }
               }
        
        heat2 = heat2.sorted { (lhs, rhs) -> Bool in
        let a = lhs.getEvent(eventName: self.title!, meetName: meet.name
            )?.place
        let b = rhs.getEvent(eventName: self.title!, meetName: meet.name)?.place
                 switch (a ,b) {
                   case let(a?, b?): return a < b // Both lhs and rhs are not nil
                   case (nil, _): return false    // Lhs is nil
                   case (_?, nil): return true    // Lhs is not nil, rhs is nil
                   }
               }
            print("sorting by place")
            
        
    }
    
    func sortByMark(){
        eventAthletes = eventAthletes.sorted { (lhs, rhs) -> Bool in
            var a = lhs.getEvent(eventName: self.title!, meetName: meet.name)?.markString
            var b = rhs.getEvent(eventName: self.title!, meetName: meet.name
                )?.markString
                       
                                        switch (a ,b) {
                                          case ("", _): return false    // Lhs is empty
                                          case (_?, ""): return true    // Lhs is not nil, rhs is empty
                                        default:
                                            // making sure they have the same length
                                           while a!.count < b!.count{a = "0\(a!)"
                                               print(a!)
                                           }
                                           while b!.count < a!.count{b = "0\(b!)"
                                               print(b!)
                                           }
                                           if fieldEventsLev.contains(self.title!){
                                           return a! > b!
                                           }
                                           else{return a! < b!}
                                          }
                                      }
        heat1 = heat1.sorted { (lhs, rhs) -> Bool in
        var a = lhs.getEvent(eventName: self.title!, meetName: meet.name)?.markString
        var b = rhs.getEvent(eventName: self.title!, meetName: meet.name
            )?.markString
                   
                                    switch (a ,b) {
                                      case ("", _): return false    // Lhs is empty
                                      case (_?, ""): return true    // Lhs is not nil, rhs is empty
                                    default:
                                       while a!.count < b!.count{a = "0\(a!)"
                                           print(a!)
                                       }
                                       while b!.count < a!.count{b = "0\(b!)"
                                           print(b!)
                                       }
                                       if fieldEventsLev.contains(self.title!){
                                       return a! > b!
                                       }
                                       else{return a! < b!}
                                      }
                                  }
        heat2 = heat2.sorted { (lhs, rhs) -> Bool in
        var a = lhs.getEvent(eventName: self.title!, meetName: meet.name)?.markString
        var b = rhs.getEvent(eventName: self.title!, meetName: meet.name
            )?.markString
                   
                                    switch (a ,b) {
                                      case ("", _): return false    // Lhs is empty
                                      case (_?, ""): return true    // Lhs is not nil, rhs is empty
                                    default:
                                       while a!.count < b!.count{a = "0\(a!)"
                                           print(a!)
                                       }
                                       while b!.count < a!.count{b = "0\(b!)"
                                           print(b!)
                                       }
                                       if fieldEventsLev.contains(self.title!){
                                       return a! > b!
                                       }
                                       else{return a! < b!}
                                      }
                                  }
                   print("sorting by mark")
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
       
        if item.title == "School"{
            sortBySchool()
        }
        else if item.title == "Name"{
             sortByName()
        }
        
        else if item.title == "Place"{
            sortByPlace()
        }
        else if item.title == "Mark"{
             sortByMark()
           
        }
        
        
        tableViewOutlet.reloadData()
        
      
        
        
    }
    
    // support functions
    func calcPoints(){
            print("starting to calculate points.  Ind points \(meet.indPoints)")
            
            var scoringAthletes = [Athlete]()
            for a in heat1{
                scoringAthletes.append(a)
            }
            for a in heat2{
                scoringAthletes.append(a)
            }
        for a in eventAthletes{
            scoringAthletes.append(a)
        }
            for a in scoringAthletes{
                
                print("Scoring \(a.last)")
                if let event = a.getEvent(eventName: self.title!, meetName: meet.name){
                    if let place = event.place{
                   // print("event.meetName \(event.meetName) meet.name \(meet.name)")
                    if event.meetName == meet.name{
                    var scoring = [Int]()
                    if event.name.contains("4x"){
                        scoring = meet.relPoints
                    }
                    else{scoring = meet.indPoints}
                    if place <= scoring.count{
                        let ties = checkForTies(place: place, athletes: scoringAthletes)
                        var points = 0
                        if ties != 0{
                            for i in place - 1 ..< place - 1 + ties{
                                if i > scoring.count - 1{
                                    points += 0
                                }
                                else{
                                    points += scoring[i]
                                    print("Added some points")
                                }
                            }
                            event.points = Double(Int(Double(points)/Double(ties)*100.0))/100.0
                            
                        }
                        else{event.points = 0}  // if ties somehow = 0
                        
                        print("\(a.last) points added = \(event.points)")
                        for blah in a.events{
                            print("\(a.last) \(blah.name) \(blah.points)")
                        }
                        
                        }
                    else{
                        event.points = 0  // if place is not for a score
                        }

            }
        }
                        // if there is no place
                    else{
                        event.points = 0
                    }
                }
        }
       
        
        tableViewOutlet.reloadData()
    }
    
    func checkForTies(place: Int, athletes: [Athlete])-> Int{
        var ties = 0
        for a in athletes{
            if let event = a.getEvent(eventName: self.title!, meetName: meet.name){
                if event.place == place{
                    ties += 1
                }
        }
    }
        return ties
    }
   
    //segue Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           print("prepare for segue")
           if segue.identifier == "unwindToEventsSegue"{
               // save to userdefaults
                  let userDefaults = UserDefaults.standard
                  do {
                          try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
                         } catch {
                             print(error.localizedDescription)
                         }
          
              //calcPoints()
              // print("Calculated Points")
           }
           else if segue.identifier == "relaySegue"{
            let nvc = segue.destination as! RelayViewController
            nvc.screenTitle = screenTitle
            nvc.meet = meet
            nvc.theSchool = selectedSchool
            nvc.theRelay = selectedRelay
            nvc.theEvent = selectedEvent
            nvc.lev = String(screenTitle.suffix(3))
            
            if let members = selectedEvent.relayMembers{
                for id in members{
                    for ath in AppData.allAthletes{
                        if ath.uid == id{
                            nvc.runners.append(ath)
                            break;
                        }
                    }
                
                }
            
           }
           }
           else{
           
           
           let nvc = segue.destination as! AddAthleteToEventViewController
          // nvc.allAthletes = allAthletes
           nvc.eventAthletes = eventAthletes
            nvc.heat1 = heat1
            nvc.heat2 = heat2
           nvc.screenTitle = screenTitle
               nvc.meet = meet
           }
       }
       
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
       meet.beenScored[selectedRow] = false
        meet.updatebeenScoredFirebase()
      processOutlet.backgroundColor = UIColor.lightGray
       processOutlet.setTitle("Process Event", for: .normal)
       
       
       
       if let pvc = seg.source as? AddAthleteToEventViewController{
         //allAthletes = pvc.allAthletes
         screenTitle = pvc.screenTitle
       eventAthletes = pvc.eventAthletes
         tableViewOutlet.reloadData()
         print("unwinding from AddAthleteToEvent")
        print("checking events after unwinding to eventeditvc")
        for ath in eventAthletes{
            for eve in ath.events{
                print("\(ath.last) \(eve.name)")
            }
        }
       }
       else{
           let pvc = seg.source as! addAthleteViewController
          // allAthletes = pvc.allAthletes
             screenTitle = pvc.from
           eventAthletes = pvc.eventAthletes
      
            
             tableViewOutlet.reloadData()
             print("unwinding from addAthlete")
           
       }
       
       // save to userdefaults
       let userDefaults = UserDefaults.standard
       do {
               try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
              } catch {
                  print(error.localizedDescription)
              }
    
     }
}

