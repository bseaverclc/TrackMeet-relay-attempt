//
//  CoachesVC.swift
//  TrackMeet
//
//  Created by Brian Seaver on 4/10/21.
//  Copyright © 2021 clc.seaver. All rights reserved.
//

import UIKit

class CoachesVC: UITableViewController {

    var school :  School!
    var canEditAthletes: Bool!

    @IBOutlet weak var addButtonOutlet: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !canEditAthletes{
            addButtonOutlet.isEnabled = false
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Coaches email", message: "", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) in
      
               textField.placeholder = "coaches email"
        })
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (updateAction) in
            
         let email = alert.textFields![0].text!
            self.school.coaches.append(email)
            self.school.updateFirebase()
            self.tableView.reloadData()
        
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return school.coaches.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)

        cell.textLabel?.text = school.coaches[indexPath.row]

        return cell
    }
   

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if canEditAthletes{return true}
        else{return false}
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if school.coaches.count > 1{
            school.coaches.remove(at: indexPath.row)
            self.school.updateFirebase()
            tableView.deleteRows(at: [indexPath], with: .fade)
            }
            else{
                let alert = UIAlertController(title: "Error", message: "You must have at least 1 coach on the team", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
