//
//  AthletesTableViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/18/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import UIKit
import Firebase

class AthletesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

   
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var coachesButtonOutlet: UIButton!
    @IBOutlet weak var uploadButtonOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBarOutlet: UITabBar!
    
     weak var delegate: DataBackDelegate?
   
    
    var canEditAthletes = false
    var header = ""
    var screenTitle = "Rosters"
    //var allAthletes = [Athlete]()
    var eventAthletes = [Athlete]()
    var displayedAthletes = [Athlete]()
    var selectedAthlete : Athlete!
    var schools = [School]()
    var meet : Meet?
    var pvcScreenTitle = ""
   // var meets : [Meet]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = Database.database().reference().child("athletes")
         ref.observe(.childChanged, with: { (snapshot) in
            print(snapshot)
            AppData.allAthletes.sort(by: {$0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})
            
     })
         
        
        
        let fontAttributes2 = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title3)]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes2, for: .normal)
         
            
           
        
        self.title = screenTitle
        displayedAthletes = AppData.allAthletes
       
        
        
        
        if pvcScreenTitle == "" {
        var schoolNames = [String](meet!.schools.keys)
            for name in schoolNames{
                for s in AppData.schoolsNew{
                    if s.full == name{
                        schools.append(s)
                        break
                    }
                }
            }
            
            stackView.isHidden = true
            //uploadButtonOutlet.isHidden = true
            
        }
        else{
            stackView.isHidden = false
        }
        
        checkEditAthletes()
        
        if !canEditAthletes{
            stackView.isHidden = true
        }
        let tabItems = tabBarOutlet.items!
             var i = 0
             for school in schools{
                tabItems[i].title = school.inits
                 i+=1
             }
        tabBar(tabBarOutlet, didSelect: tabBarOutlet.items![0])
        
        print(AppData.schoolsNew)
        print("ViewDidLoad in AthletesViewController")
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        tableView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view disappearing")
        if isMovingFromParent{
            if let del = self.delegate{
        del.savePreferences(athletes: AppData.allAthletes)
            }
            else{
                performSegue(withIdentifier: "unwindtoSchoolsSegue", sender: nil)
            }
            print("is moving from parent")
        }
    }
    
    func checkEditAthletes(){
        if(AppData.userID == "SRrCKcYVC8U6aZTMv0XCYHHR4BG3")
        {
            canEditAthletes = true
            return
        }
        
        if let m = meet{
            print("In a meeet checking management")
            if Meet.canManage || Meet.canCoach{
                canEditAthletes = true
                return
            }
            
        }
        
        if let cu = Auth.auth().currentUser?.email{
            for e in schools[0].coaches{
                print("printing coaches email \(e)")
   
                if cu == e{
                    
                    canEditAthletes = true
                    return
                }
            }
        }
            
        
        canEditAthletes = false
        print("You are not a valid coach for this team or a Meet Manager")
    }
    
    @IBAction func addAthleteAction(_ sender: UIBarButtonItem) {
        
        if canEditAthletes{
            performSegue(withIdentifier: "toAddAthleteSegue", sender: self)
        }
        else{
            let denyAlert = UIAlertController(title: "Error", message: "You don't have permission to add athletes", preferredStyle: .alert)
            denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(denyAlert, animated: true, completion: nil)
            
        }
        
//        if let m = meet{
//
//            if Meet.canManage || Meet.canCoach{
//                performSegue(withIdentifier: "toAddAthleteSegue", sender: self)
//                return
//            }
//
//        }
//        for s in AppData.schoolsNew{
//            if s.full == schools[0]{
//            for e in s.coaches{
//                if Auth.auth().currentUser?.email == e{
//                    performSegue(withIdentifier: "toAddAthleteSegue", sender: self)
//                    return
//                }
//            }
//            }
//        }
//        print("You are not a valid coach for this team or a Meet Manager")
        
        
    }
    
   

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return displayedAthletes.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let athlete = displayedAthletes[indexPath.row]
        cell.textLabel?.text = "\(athlete.last), \(athlete.first) (\(athlete.grade))"
        cell.detailTextLabel?.text = "\(athlete.school)"
       
        //print(athlete.grade)
        return cell
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
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            if !self.canEditAthletes{
                let denyAlert = UIAlertController(title: "Error", message: "You don't have permission to delete athletes", preferredStyle: .alert)
                denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(denyAlert, animated: true, completion: nil)
                
            }
            if !self.canEditAthletes{
                return
            }
            
            
            
            let alert = UIAlertController(title: "Are you sure?", message: "Deleting this athlete will also delete any results stored for this athlete", preferredStyle:    .alert)
            let ok = UIAlertAction(title: "Delete", style: .destructive) { (a) in
                let selected = self.displayedAthletes[indexPath.row]
                AppData.allAthletes.removeAll { (athlete) -> Bool in
                    athlete.equals(other: selected)
               
                }
                selected.deleteFromFirebase()
                     self.displayedAthletes.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
            
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
                
                if !self.canEditAthletes{
                    let denyAlert = UIAlertController(title: "Error", message: "You don't have permission to edit athletes", preferredStyle: .alert)
                    denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(denyAlert, animated: true, completion: nil)
                    
                }
                if !self.canEditAthletes{
                    return
                }
                
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
                  
                    if !self.canEditAthletes{
                        let denyAlert = UIAlertController(title: "Error", message: "You don't have permission to edit athletes", preferredStyle: .alert)
                        denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(denyAlert, animated: true, completion: nil)
                        return
                    }
                    
                    self.displayedAthletes[indexPath.row].first = alert.textFields![0].text!
                    self.displayedAthletes[indexPath.row].last = alert.textFields![1].text!
                    //self.displayedAthletes[indexPath.row].school = alert.textFields![2].text!
                    if let grade = Int(alert.textFields![2].text!){
                        self.displayedAthletes[indexPath.row].grade = grade}
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                    for i in 0 ..< AppData.allAthletes.count{
                       if self.displayedAthletes[indexPath.row].equals(other: AppData.allAthletes[i]){
                        AppData.allAthletes[i].first = alert.textFields![0].text!
                         AppData.allAthletes[i].last = alert.textFields![1].text!
                        // AppData.allAthletes[i].school = alert.textFields![2].text!
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

        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAthlete = displayedAthletes[indexPath.row]
        performSegue(withIdentifier: "toAthleteResultsSegue", sender: self)
    }
  
    
//     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//
//        if editingStyle == .delete{
//
//            var selected = displayedAthletes[indexPath.row]
//            for i in 0 ..< allAthletes.count{
//                if selected.equals(other: allAthletes[i]){
//                    allAthletes.remove(at: i)
//                    break
//                }
//            }
//            displayedAthletes.remove(at: indexPath.row)
//                   tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    
//     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        var selectedAthlete = displayedAthletes[indexPath.row]
//        selectedAthlete.events.append(Event(name: self.title!, level: "varsity"))
//        eventAthletes.append(selectedAthlete)
//        performSegue(withIdentifier: "backToEventSegue", sender: nil)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "backToEventSegue"{
        let nvc = segue.destination as! EventEditViewController
        nvc.eventAthletes = eventAthletes
       // nvc.allAthletes = allAthletes
        }
        else if segue.identifier == "toAddAthleteSegue"{
       
            
            
            let nvc = segue.destination as! addAthleteViewController
            nvc.displayedAthletes = displayedAthletes
           // nvc.allAthletes = allAthletes
            if let aMeet = meet{
                nvc.meet = aMeet
            }
            else{
                nvc.meet = Meet(name: "Blank", date: Date(), schools: [schools[0].full:schools[0].inits], gender: "M", levels: ["VAR"], events: ["none"], indPoints: [Int](), relpoints: [Int](), beenScored: [false], coach: "", manager: "")
            }
            nvc.from = "AthletesVC"
        }
        else if segue.identifier == "toAthleteResultsSegue"{
            let nvc = segue.destination as! AthleteResultsViewController
            nvc.athlete = selectedAthlete
           // nvc.meets = meets
            nvc.meet = meet
        }
        else if segue.identifier == "toCoachesSegue"{
            let nvc = segue.destination as! CoachesVC
            nvc.school = schools[0]
     
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        displayedAthletes = [Athlete]()
        for a in AppData.allAthletes{

            if item.title == a.school && schools.contains(where: {($0.full == a.schoolFull)}){
                displayedAthletes.append(a)
            }
        }
        //self.title = item.title
        header = item.title!
        self.tableView.reloadData()
        
    }
    
   @IBAction func unwind( _ seg: UIStoryboardSegue) {
    let pvc = seg.source as! addAthleteViewController
   // allAthletes = pvc.allAthletes
    displayedAthletes = pvc.displayedAthletes
    tableView.reloadData()
    print("unwinding")
    
   }

   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return header
    }
    
    func displayRosterAlert(error: String){
        let rosterAlert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        rosterAlert.addAction(okAction)
        self.present(rosterAlert, animated: true, completion: nil)
        }

    
    func readCSVURLNew(csvURL: String, fullSchool: String, initSchool: String) -> String{
       var err = ""
        
        var urlCut = csvURL
        if csvURL != ""{
            if let editRange = csvURL.range(of: "/edit"){
            let start = editRange.lowerBound
            urlCut = String(csvURL[csvURL.startIndex..<start])
            }
            else{
                
                return "Must have /edit in URL"
            }
            let urlcompleted = urlCut + "/pub?output=csv"
            let url = URL(string: String(urlcompleted))
            print(url ?? "Error reading URL")
            
                 guard let requestUrl = url else {
                    //fatalError()
                    print("fatal error")
                    
                    return "Error reading URL"
            }
                 // Create URL Request
                 var request = URLRequest(url: requestUrl)
                 // Specify HTTP Method to use
                 request.httpMethod = "GET"
            
                 // Send HTTP Request
                 let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                   
                     // Check if Error took place
                     if let error = error {
                         print("Error took place \(error)")
                        err = "\(error)"
                        
                        
                        
                        
//                        let alert = UIAlertController(title: "Error!", message: "Could not load athletes", preferredStyle: .alert)
//                        let ok = UIAlertAction(title: "ok", style: .default)
//                        alert.addAction(ok)
//                        self.present(alert, animated: true, completion: nil)
                        //self.showAlert(errorMessage: "Error loading Athletes from file")
                         
                     }
                     
                     // Read HTTP Response Status code
                     if let response = response as? HTTPURLResponse {
                         print("Response HTTP Status code: \(response.statusCode)")
                        if response.statusCode == 400{
                            err = "can't read roster"
                        }
                     }
                    
                     
                     
                     
                     
                     // Convert HTTP Response Data to a simple String
                     if let data = data, let dataString = String(data: data, encoding: .utf8) {
                         print("Response data string:\n \(dataString)")
                         let rows = dataString.components(separatedBy: "\r\n")
                        print(rows.count)
                        if rows.count == 1{
                            err = "can't read roster"
                            print(err)
                            
                        }
                        else{
                         for row in rows{
                            
                            var person = [String](row.components(separatedBy: ","))
                            if person.count != 3{
                                
                                continue
                            }
                            for i in 0..<person.count{
                                person[i] = person[i].uppercased()
                            }
                            if person[0] != "FIRST"{
                                print("\(person[0])  \(person[1])   \(person[2])")
                                
                                let athlete = Athlete(f: person[0], l: person[1], s: initSchool, g: Int(person[2]) ?? 0, sf: fullSchool)
                            print(athlete)
                                var found = false
                                for a in self.displayedAthletes{
                                    if athlete.equals(other: a){
                                        found = true
                                        break
                                    }
                                }
                                if !found{
                                    athlete.saveToFirebase()
                                    AppData.allAthletes.append(athlete)
                                    self.displayedAthletes.append(athlete)
                                    
                                }
                                
                            }
                         }
                            
                         }
                        
                     }
                     else{
                        err = "error with url"
                     }
                     
                     
                        
                     

                    
                 }
                 task.resume()
            
        
    }
        self.tableView.reloadData()
    return err
    
}
    
    
    @IBAction func uploadAction(_ sender: UIButton) {
        
            
                if(!canEditAthletes)
                {
                    let denyAlert = UIAlertController(title: "Error", message: "You are not authorized to upload a roster", preferredStyle: .alert)
                    denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(denyAlert, animated: true, completion: nil)
                }
                else{
                
                let alert = UIAlertController(title: "upload Roster", message: "copy and paste url", preferredStyle: .alert)
                
                alert.addTextField(configurationHandler: { (textField) in
                     
                              textField.placeholder = "Roster csv url"
                       })
                       
                       alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (updateAction) in
                           var badInput = false
                           var error = ""
                       
                        let csvURL = alert.textFields![0].text!
                           
                           
                        if !badInput{
                               if csvURL != ""{
                                
                                    error =  self.readCSVURLNew(csvURL: csvURL, fullSchool: self.schools[0].full, initSchool: self.schools[0].inits)
                                if error != ""{
                                    //self.displayRosterAlert(error: e)
                                    badInput = true
                                }
                              
                               }
                               else{badInput = true
                                error = "can't leave url blank"
                               }
                                       
                   
                            
                        }
                           //}
                           if badInput{
                            self.displayRosterAlert(error: error)
        //                   let alert2 = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        //                   let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        //                   alert2.addAction(okAction)
        //                   self.present(alert2, animated: true, completion: nil)
                           }
                       }))
                   
                       alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                      present(alert, animated: true, completion: nil)
                }
            }
    
    
    
}
