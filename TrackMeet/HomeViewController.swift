//
//  HomeViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/18/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import UIKit
import Firebase

public protocol DataBackDelegate: class {
    func savePreferences (athletes: [Athlete])
}


class HomeViewController: UIViewController, DataBackDelegate {
    
   // var allAthletes : [Athlete]!
    var meet : Meet!
    //var meets : [Meet]!
    var ref: DatabaseReference!
    
    
    func savePreferences(athletes: [Athlete]) {
        AppData.allAthletes = athletes
        AppData.allAthletes.sort(by: {$0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})
        print("delegate function called")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent{
            performSegue(withIdentifier: "unwindToMeetsVC", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    

   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(meet.gender)
        print("Individual Points: \(meet.indPoints)")
        self.title = "\(meet.name) Home"
        
        
        
        if(meet.userId == AppData.userID)
        {
            Meet.canCoach = true
            Meet.canManage = true
        }
        AppData.allAthletes.sort(by: {$0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})
        
        
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.description)
        if segue.identifier == "eventsSegue"{
            let nvc = segue.destination as! EventsTableViewController
           // nvc.athletes = allAthletes
            //nvc.events = meet.events
            nvc.meet = meet
            
            
        }
        else if segue.identifier == "scoresSegue"{
            let nvc = segue.destination as! ScoresViewController
            //nvc.allAthletes = allAthletes
            nvc.meet = meet
        }
        else if segue.identifier == "athletesSegue"{
            let nvc = segue.destination as! AthletesViewController
            //nvc.allAthletes = allAthletes
            nvc.delegate = self
            nvc.meet = meet
            //nvc.meets = meets
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
   @IBAction func unwind( _ seg: UIStoryboardSegue) {
   // let pvc = seg.source as! EventsTableViewController
   // allAthletes = pvc.athletes
    AppData.allAthletes.sort(by: {$0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending})
    print("unwind to home screen")
    
    
    }
    

//    @IBAction func apiTestAction(_ sender: UIButton) {
//        
//       let configuration = URLSessionConfiguration.default
//           let session = URLSession(configuration: configuration)
//        let url = URL(string: "https://docs.google.com/spreadsheets/d/1puxn4zdVrYcJwrEksSktMF-McK6VQhguOqnPOLjaSYQ/edit#gid=0")
//           //let url = NSURL(string: urlString as String)
//           var request : URLRequest = URLRequest(url: url!)
//        https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values:batchGet
//           request.httpMethod = "GET"
//       
//           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//           request.addValue("application/json", forHTTPHeaderField: "Accept")
//           let dataTask = session.dataTask(with: url!) { data,response,error in
//              // 1: Check HTTP Response for successful GET request
//              guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
//              else {
//                 print("error: not a valid http response")
//                 return
//              }
//              switch (httpResponse.statusCode) {
//                 case 200:
//                    //success response.
//                    break
//                 case 400:
//                    break
//                 default:
//                    break
//              }
//           }
//           dataTask.resume()
//        }
//    
}
