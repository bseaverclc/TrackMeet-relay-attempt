//
//  SchoolsViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 7/13/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import UIKit
import Firebase

class SchoolsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

   
    @IBOutlet weak var tableView: UITableView!
    
        
         //weak var delegate: DataBackDelegate?
       
        var canEditSchools = false
        var header = "Schools"
        var screenTitle = "Schools"
        //var allAthletes = [Athlete]()
        var eventAthletes = [Athlete]()
        var displayedAthletes = [Athlete]()
        var selectedSchool : School!
       // var schools = [String:String]()
        //var schoolNames = [String]()
        var initials = [String]()
        //var meets : [Meet]!
   
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.delegate = self
            tableView.dataSource = self
            
            self.title = screenTitle
//            for sch in AppData.schoolsNew{
//                schoolNames.append(sch.full)
//
//            }
//            schoolNames.sort()
            
            AppData.schoolsNew.sort(by: {$0.full < $1.full})
            
    
            
            
            if(AppData.userID == "SRrCKcYVC8U6aZTMv0XCYHHR4BG3"){
                canEditSchools = true
            }
            
            
            print("ViewDidLoad in SchoolsViewController")
           
        }
        
        override func viewDidAppear(_ animated: Bool) {
            print("viewDidAppear")
            tableView.reloadData()
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent{
            performSegue(withIdentifier: "unwindFromSchoolsSegue", sender: nil)
        }
        //storeToUserDefaults()
    }
    
    

         func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }

         func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return AppData.schoolsNew.count
        }

        
         func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
            let school = AppData.schoolsNew[indexPath.row]
            cell.textLabel?.text = school.full
            cell.detailTextLabel?.text = school.inits
            //print(athlete.grade)
            return cell
        }
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            //var blankText = false
            var blankAlert = UIAlertController()
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                
                let theSchool = AppData.schoolsNew[indexPath.row]
                for e in theSchool.coaches{
                    if Auth.auth().currentUser?.email == e{
                     self.canEditSchools = true
                        break
                
                    }
                }
//                for s in AppData.schoolsNew{
//                    if s.full == self.schoolNames[indexPath.row]{
//                    for e in s.coaches{
//                        if Auth.auth().currentUser?.email == e{
//                            self.canEditSchools = true
//
//                        }
//                    }
//                    }
//                }
                
                //right now, only I can delete schools
                if(AppData.userID == "SRrCKcYVC8U6aZTMv0XCYHHR4BG3") // || self.canEditSchools
                {
                
                let alert = UIAlertController(title: "Are you sure?", message: "Deleting this school will delete all the school's athletes and results", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let ok = UIAlertAction(title: "Delete", style: .destructive) { (a) in
                   // let selected = self.schoolNames[indexPath.row]
                    // removing all athletes from app with this school name
                   // AppData.allAthletes.removeAll(where: {$0.schoolFull == selected})
                    
                    //attempt to delete from firebase and AppData.allAthletes
                    // crashes sometimes.  I think it is when it tries to remove the last athlete
                    
                    theSchool.deleteFromFirebase()
                    
//                    for s in AppData.schoolsNew{
//                        if s.full == self.schoolNames[indexPath.row]{
//                            s.deleteFromFirebase()
//                        }
//                    }
                    if AppData.allAthletes.count > 0{
                    for i in (0...(AppData.allAthletes.count - 1)).reversed() {
                        if AppData.allAthletes[i].schoolFull == theSchool.full{
                            AppData.allAthletes[i].deleteFromFirebase()
                            AppData.allAthletes.remove(at: i)
                            
                            
                        }
                    }
                    }
                    
                   // Skipped some to delete
//                    for (index, item) in AppData.allAthletes.enumerated().reversed() {
//                        if index < AppData.allAthletes.count{
//                        if item.schoolFull == selected{
//                            print(index)
//                            AppData.allAthletes.remove(at: index)
//                            item.deleteFromFirebase()
//
//
//                        }
//                        }
//                    }
                    
                    
                    
                   // self.schoolNames.remove(at: indexPath.row) // remove from array
                   // AppData.schools.removeValue(forKey: selected) // remove from dictionary
                    // Database.database().reference().child("schools").child(selected).removeValue()
                    
                    // Still need to remove all athletes from this school
                   // tableView.deleteRows(at: [indexPath], with: .fade)
                    AppData.schoolsNew.remove(at: indexPath.row)
                    self.tableView.reloadData()
                    
//                    let userDefaults = UserDefaults.standard
//                    do {
//                        try userDefaults.setObjects(AppData.schools, forKey: "schools")
//                       print("Saving Schools")
//                    }
//                    catch{
//                          print("error saving schools")
//                    }
                }
                    
                    alert.addAction(ok)
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                    
            }
                else
                {
                    let denyAlert = UIAlertController(title: "Error", message: "Contact developer at bseaver@d155.org to edit schoool name or delete school", preferredStyle: .alert)
                    denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(denyAlert, animated: true, completion: nil)
                }
                
                
            }
  
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
                if(AppData.userID != "SRrCKcYVC8U6aZTMv0XCYHHR4BG3")
                {
                    let denyAlert = UIAlertController(title: "Error", message: "Contact developer at bseaver@d155.org to edit schoool name or delete school", preferredStyle: .alert)
                    denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(denyAlert, animated: true, completion: nil)
                }
                else{
                
                let alert = UIAlertController(title: "", message: "Edit School", preferredStyle: .alert)
                    alert.addTextField(configurationHandler: { (textField) in
                         textField.autocapitalizationType = .allCharacters
                        textField.text = AppData.schoolsNew[indexPath.row].full
                        
                    })
                alert.addTextField(configurationHandler: { (textField) in
                     textField.autocapitalizationType = .allCharacters
                    textField.text = AppData.schoolsNew[indexPath.row].inits
                    
                })
              
                    alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                        if alert.textFields![0].text! != "" && alert.textFields![1].text! != ""{
                        
                            //changing school names to new names
                            
                            for a in AppData.allAthletes{
                                        print(a.schoolFull)
                                        
                                        if a.schoolFull == AppData.schoolsNew[indexPath.row].full{
                                            a.schoolFull = alert.textFields![0].text!
                                            a.school = alert.textFields![1].text!
                                            print("changed athletes school")
                                            a.updateFirebase()
                                        }
                                    }
                            
                            // changing all meets to new school names
                            for m in AppData.meets{
                                m.schools.removeValue(forKey: AppData.schoolsNew[indexPath.row].full)
                                m.schools[alert.textFields![0].text!] = alert.textFields![1].text!
                                
                            
                            }
                            
                            // update schoolsNew on Firebase and in AppData.schoolsNew
                            for s in AppData.schoolsNew{
                                if s.full == AppData.schoolsNew[indexPath.row].full{
                                    s.full = alert.textFields![0].text!
                                    s.inits = alert.textFields![1].text!
                                    s.updateFirebase()
                                    break
                                }
                            }
                            
                           
                            
                              
                           
                            // remove old from Dict
//                            AppData.schools.removeValue(forKey: AppData.schoolsNew[indexPath.row].full)
//                            // add new to dict
//                            AppData.schools[alert.textFields![0].text!] = alert.textFields![1].text!
//                            // update Array of Schools
//                        self.schoolNames[indexPath.row] = alert.textFields![0].text!
//
//                            // updateFirebase for schools dictionary
//                            let ref = Database.database().reference().child("schools")
//
//                            // remove entire dictionary from firebase
//                             Database.database().reference().child("schools").removeValue()
//                            // write new values to firebase
//                            ref.updateChildValues(AppData.schools)
                            
                            
                            
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
                            
                            
                            
//                             let userDefaults = UserDefaults.standard
//
//
//
//                                          do {
//                                            try userDefaults.setObjects(AppData.meets, forKey: "meets")
//
//                                                 } catch {
//                                                     print(error.localizedDescription)
//                                                 }
//                                       do {
//                                        try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
//                                           print("Saving Athletes")
//                                       }
//                                       catch{
//                                           print("error saving athletes")
//                                       }
//
//                                       do {
//                                        try userDefaults.setObjects(AppData.schools, forKey: "schools")
//                                                      print("Saving Schools")
//                                                  }
//                                                  catch{
//                                                      print("error saving schools")
//                                                  }
                                   
                      
                        }
                        else{
                            //blankText = true
                            print("textfields are blank")
                            blankAlert = UIAlertController(title: "Error!", message: "Can't have blank fields", preferredStyle: .alert)
                                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                                blankAlert.addAction(ok)
                            self.present(blankAlert, animated: true, completion: nil)
                        }
                        
                    }))
                
            
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               
                self.present(alert, animated: true) {
                   
                            
                        }
                
            }
                  

            
            }
            edit.backgroundColor = UIColor.blue
            

            return [delete, edit]
        }
    
    func displayRosterAlert(error: String){
        let rosterAlert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        rosterAlert.addAction(okAction)
        self.present(rosterAlert, animated: true, completion: nil)
        }
    
    
    @IBAction func addSchoolActionNew2(_ sender: UIBarButtonItem) {
        if(AppData.userID == "")
        {
            let denyAlert = UIAlertController(title: "Error", message: "Must login on main page to add a school", preferredStyle: .alert)
            denyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(denyAlert, animated: true, completion: nil)
        }
        else{
        var gender = ""
        let alert = UIAlertController(title: "Add School", message: "", preferredStyle: .alert)
        let genderAlert = UIAlertController(title: "Gender", message: "Men or Women?", preferredStyle: .alert)
        genderAlert.addAction(UIAlertAction(title: "Men", style: .default, handler: { (action) in
            gender = "(M)"
            self.present(alert, animated: true, completion: nil)
        }))
        genderAlert.addAction(UIAlertAction(title: "Women", style: .default, handler: { (action) in
            gender = "(W)"
            self.present(alert, animated: true, completion: nil)
        }))
        genderAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               
               alert.addTextField(configurationHandler: { (textField) in
                   textField.autocapitalizationType = .allCharacters
                   textField.placeholder = "Full School Name"
                   
               })
               
               alert.addTextField(configurationHandler: { (textField) in
                   textField.autocapitalizationType = .allCharacters
                          textField.placeholder = "School Initials"
                          
                      })
        
        
               alert.addTextField(configurationHandler: { (textField) in
             
                      textField.placeholder = "Roster csv url"
               })
               
               alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (updateAction) in
                   var badInput = false
                   var error = ""
                let fullSchool = alert.textFields![0].text!
                let initSchool = alert.textFields![1].text!
                let csvURL = alert.textFields![2].text!
                   if fullSchool == ""{
                       error = "Must include school name"
                       badInput = true
                   }
                   else if initSchool == ""{
                       error = "Must include school initials"
                       badInput = true
                   }
                   
                for school in AppData.schoolsNew{
                    if (school.full == "\(fullSchool) \(gender)"){
                        error = "\(fullSchool) \(gender) is already in database"
                        badInput = true
                        break;
                    }
                    else if school.inits == initSchool && gender == school.full.suffix(3){
                        error = "The initials \(initSchool)\(gender) are already in use"
                        badInput = true
                        break;
                    }

                }
                   
//                   else if self.schoolKeys.contains("\(fullSchool) \(gender)"){
//                       error = "\(fullSchool) \(gender) is already in database"
//                       badInput = true
//                   }
//                   else if self.initials.contains(initSchool){
//                       error = "The initials \(initSchool)\(gender) are already in use"
//                       badInput = true
//                   }
                   
                if !badInput{
                       if csvURL != ""{
                          error =  self.readCSVURLNew(csvURL: csvURL, fullSchool: "\(fullSchool) \(gender)", initSchool: initSchool)
                        if error != ""{
                            //self.displayRosterAlert(error: e)
                            badInput = true
                        }
                       }
                               
           
                    if !badInput{
                    //AppData.schools["\(fullSchool) \(gender)"] = alert.textFields![1].text!
                        let newSchool = School(full: "\(fullSchool) \(gender)", inits: alert.textFields![1].text!)
                        
                        AppData.schoolsNew.append(newSchool)
                        print("added school to schoolsNew in !badInput")
                        if let user = Auth.auth().currentUser{
                            newSchool.addCoach(email: user.email!)
                        }
                        
                        // Save schoolsNew to firebase
                        // This also adds the school to AppData.schoolsNew
                        newSchool.saveToFirebase()
                        self.tableView.reloadData()
                    
                       
                       //Save schools to firebase
//                    let ref = Database.database().reference().child("schools")
//                    ref.updateChildValues(AppData.schools)
//
//                       // Save school to UserDefaults
//                       let userDefaults = UserDefaults.standard
//                       do {
//                           try userDefaults.setObjects(AppData.schools, forKey: "schools")
//                           print("Saved Schools in Add Meet VC")
//                              } catch {
//                                  print(error.localizedDescription)
//                               print("Error saving schools in AddMeet")
//                              }
//
//                       do {
//                        try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
//                                   print("Saving Athletes")
//                               }
//                               catch{
//                                   print("error saving athletes")
//                               }
                        
                       
                       
                       //self.schoolNames.insert("\(fullSchool) \(gender)", at: 0)
                       
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
        present(genderAlert, animated: true, completion: nil)
        }
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
                                athlete.saveToFirebase()
                                AppData.allAthletes.append(athlete)
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
        
    return err
    
}
    
//    @IBAction func addSchoolAction(_ sender: UIBarButtonItem) {
//        var gender = ""
//        let alert = UIAlertController(title: "Add School", message: "", preferredStyle: .alert)
//        let genderAlert = UIAlertController(title: "Gender", message: "Men or Women?", preferredStyle: .alert)
//        genderAlert.addAction(UIAlertAction(title: "Men", style: .default, handler: { (action) in
//            gender = "(M)"
//            self.present(alert, animated: true, completion: nil)
//        }))
//        genderAlert.addAction(UIAlertAction(title: "Women", style: .default, handler: { (action) in
//            gender = "(W)"
//            self.present(alert, animated: true, completion: nil)
//        }))
//        genderAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//               alert.addTextField(configurationHandler: { (textField) in
//                   textField.autocapitalizationType = .allCharacters
//                   textField.placeholder = "Full School Name"
//
//               })
//
//               alert.addTextField(configurationHandler: { (textField) in
//                   textField.autocapitalizationType = .allCharacters
//                          textField.placeholder = "School Initials"
//
//                      })
//
//
//               alert.addTextField(configurationHandler: { (textField) in
//
//                      textField.placeholder = "Roster csv url"
//               })
//
//               alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (updateAction) in
//                   var badInput = false
//                   var error = ""
//                let fullSchool = alert.textFields![0].text!
//                let initSchool = alert.textFields![1].text!
//                let csvURL = alert.textFields![2].text!
//                   if fullSchool == ""{
//                       error = "Must include school name"
//                       badInput = true
//                   }
//                   else if initSchool == ""{
//                       error = "Must include school initials"
//                       badInput = true
//                   }
//                   else if AppData.schoolsNew.contains(where: { $0.full == "\(fullSchool) \(gender)" }) {
//                    error = "\(fullSchool) \(gender) is already in database"
//                    badInput = true
//                     }
//
////                   else if self.schoolNames.contains("\(fullSchool) \(gender)"){
////                       error = "\(fullSchool) \(gender) is already in database"
////                       badInput = true
////                   }
//
//                   else if AppData.schoolsNew.contains(where: { $0.inits == initSchool }) {
//                    error = "The initials \(initSchool) are already in use"
//                    badInput = true
//                     }
//
////                   else if self.initials.contains(initSchool){
////                       error = "The initials \(initSchool) are already in use"
////                       badInput = true
////                   }
//
//                   else{
//                       if csvURL != ""{
//                           self.readCSVURL(csvURL: csvURL, fullSchool: "\(fullSchool) \(gender)", initSchool: initSchool)
//
//                       }
//
//
//
//                    //AppData.schools["\(fullSchool) \(gender)"] = alert.textFields![1].text!
//                    let newSchool = School(full: "\(fullSchool) \(gender)", inits: alert.textFields![1].text!)
//                    AppData.schoolsNew.append(newSchool)
//                    print("add to schoolsNew in addSchool")
//                    newSchool.saveToFirebase()
//
//                       //Save schools to firebase
////                    let ref = Database.database().reference().child("schools")
////                    ref.updateChildValues(AppData.schools)
//
//                       // Save school to UserDefaults
////                       let userDefaults = UserDefaults.standard
////                       do {
////                        try userDefaults.setObjects(AppData.schools, forKey: "schools")
////                           print("Saved Schools in Add Meet VC")
////                              } catch {
////                                  print(error.localizedDescription)
////                               print("Error saving schools in AddMeet")
////                              }
////
////                       do {
////                        try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
////                                   print("Saving Athletes")
////                               }
////                               catch{
////                                   print("error saving athletes")
////                               }
////
////
////
////                       self.schoolNames.append("\(fullSchool) \(gender)")
//                       self.tableView.reloadData()
//                   }
//                   if badInput{
//                   let alert2 = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
//                   let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                   alert2.addAction(okAction)
//                   self.present(alert2, animated: true, completion: nil)
//                   }
//               }))
//
//               alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        present(genderAlert, animated: true, completion: nil)
//
//    }
    
    
    
    func readCSVURL(csvURL: String, fullSchool: String, initSchool: String){
            var urlCut = csvURL
            if csvURL != ""{
                if let editRange = csvURL.range(of: "/edit"){
                let start = editRange.lowerBound
                urlCut = String(csvURL[csvURL.startIndex..<start])
                }
                let urlcompleted = urlCut + "/pub?output=csv"
                let url = URL(string: String(urlcompleted))
                print(url ?? "Error reading url")
                
                     guard let requestUrl = url else {
                        //fatalError()
                        print("fatal error")
                        return
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
    //                        let alert = UIAlertController(title: "Error!", message: "Could not load athletes", preferredStyle: .alert)
    //                        let ok = UIAlertAction(title: "ok", style: .default)
    //                        alert.addAction(ok)
    //                        self.present(alert, animated: true, completion: nil)
                            //self.showAlert(errorMessage: "Error loading Athletes from file")
                             
                         }
                         
                         // Read HTTP Response Status code
                         if let response = response as? HTTPURLResponse {
                             print("Response HTTP Status code: \(response.statusCode)")
                           
                            //return
                         }
                         
                         
                         // Convert HTTP Response Data to a simple String
                         if let data = data, let dataString = String(data: data, encoding: .utf8) {
                             print("Response data string:\n \(dataString)")
                             let rows = dataString.components(separatedBy: "\r\n")
                             for row in rows{
                                
                                let person = [String](row.components(separatedBy: ","))
                                if person[0] != "First"{
                                    let athlete = Athlete(f: person[0], l: person[1], s: initSchool, g: Int(person[2])!, sf: fullSchool)
                                print(athlete)
                                    athlete.saveToFirebase()
                                    AppData.allAthletes.append(athlete)
                                }
                                 
                             }
                         }
                         
                            
                         

                        
                     }
                     task.resume()
            
        }
        
        
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSchool = AppData.schoolsNew[indexPath.row]
        performSegue(withIdentifier: "toAthletesSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAthletesSegue"{
        let nvc = segue.destination as! AthletesViewController
        nvc.pvcScreenTitle = screenTitle
       // nvc.allAthletes = allAthletes
           // nvc.meets = meets
            nvc.schools.append(selectedSchool)
        }
        AppData.allAthletes.sort(by: {$0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})
    }
    
    @IBAction func unwindtoSchools( _ seg: UIStoryboardSegue) {
      //let pvc = seg.source as! AthletesViewController
      // allAthletes = pvc.allAthletes
        AppData.allAthletes.sort(by: {$0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})
       print("unwind to schools")
       
       
       }
    
//    func storeToUserDefaults(){
//        let userDefaults = UserDefaults.standard
//           do {
//            try userDefaults.setObjects(AppData.meets, forKey: "meets")
//            
//                  } catch {
//                      print(error.localizedDescription)
//                  }
//        do {
//            try userDefaults.setObjects(AppData.allAthletes, forKey: "allAthletes")
//            print("Saving Athletes")
//        }
//        catch{
//            print("error saving athletes")
//        }
//        
//        do {
//            try userDefaults.setObjects(AppData.schools, forKey: "schools")
//                       print("Saving Schools")
//                   }
//                   catch{
//                       print("error saving schools")
//                   }
//    }
      
        
    }
