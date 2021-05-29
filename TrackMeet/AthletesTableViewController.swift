//
//  AthletesTableViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/18/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import UIKit

class AthletesTableViewController:  UITableViewController, UITabBarDelegate {

   
    @IBOutlet weak var tabBarOutlet: UITabBar!
    var screenTitle = "All Schools"
    var allAthletes = [Athlete]()
    var eventAthletes = [Athlete]()
    var displayedAthletes = [Athlete]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = screenTitle
        displayedAthletes = allAthletes
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return displayedAthletes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let athlete = displayedAthletes[indexPath.row]
        cell.textLabel?.text = "\(athlete.last), \(athlete.first)"
        cell.detailTextLabel?.text = "\(athlete.school)"
        //print(athlete.grade)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select row at")
        var selectedAthlete = displayedAthletes[indexPath.row]
        selectedAthlete.events.append(Event(name: self.title!, level: "varsity"))
        eventAthletes.append(selectedAthlete)
        performSegue(withIdentifier: "unwindToEventEdit", sender: self)
    }
    

    

    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        displayedAthletes = [Athlete]()
        for a in allAthletes{
        
            if item.title == a.school{
                displayedAthletes.append(a)
            }
        }
        self.title = item.title
        self.tableView.reloadData()
        
    }
   

}
