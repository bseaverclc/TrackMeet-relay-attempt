//
//  AddEventToAthleteViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/29/21.
//  Copyright © 2021 clc.seaver. All rights reserved.
//

import UIKit

class AddEventToAthleteViewController: UITableViewController {
    var meet: Meet!
    var athlete: Athlete!
    var thisMeetEvents: [Event]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        
    }
    override func viewWillDisappear(_ animated: Bool) {
        selectEvents()
        performSegue(withIdentifier: "unwindToAthlete", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return meet.events.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)

        cell.backgroundColor = UIColor.white
        cell.textLabel?.text = meet.events[indexPath.row]
        if indexPath.row % 2 != 0{
            cell.backgroundColor = UIColor.lightGray
        }
        
        let view = UIView()
        view.backgroundColor = UIColor.green
        cell.selectedBackgroundView = view

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var errorMessage = ""
        var error = false;
        let selectedEvent = meet.events[indexPath.row]
        if selectedEvent.contains("4x"){
            errorMessage = "Can't add a relay to an athlete. You need to go to Events and add athlete to relay "
            error = true
        }
        for e in thisMeetEvents{
            if e.name == selectedEvent{
                errorMessage = "Athlete already in this event"
                error = true
            }
        }
       
        if error{
            let alert = UIAlertController(title: "Error!", message: errorMessage, preferredStyle: .alert)
            let action = UIAlertAction(title: "ok", style: .cancel) { (action) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            alert.addAction(action)
           present(alert, animated: true, completion: nil)
            
        } else {
        
        //print(selectedAthlete.first)
      
        }
    }
    
   
    
    func selectEvents(){
        if let selectedPaths = tableView.indexPathsForSelectedRows{
                 print(selectedPaths)
                 for path in selectedPaths{
                    let selectedEvent = meet.events[path.row]
                    
                     
                    var newEvent = Event(name: selectedEvent, level: "\(selectedEvent.suffix(3))", meetName: meet.name)
                    athlete.addEvent(e: newEvent)
                     thisMeetEvents.append(newEvent)
                 }
            
        }
    }

}
