//
//  AddSchoolsViewController.swift
//  TrackMeet
//
//  Created by Brian Seaver on 6/13/21.
//  Copyright © 2021 clc.seaver. All rights reserved.
//

import UIKit

class AddSchoolsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    @IBOutlet weak var chooseButtonOutlet: UIButton!
    @IBOutlet weak var tableViewOutlet: UITableView!
    var selectedSchools = [School]()
    var selectedMeet : Meet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewOutlet.dataSource = self
        tableViewOutlet.delegate = self
        
        AppData.schoolsNew.sort(by: {$0.full.localizedCaseInsensitiveCompare($1.full) == .orderedAscending})

        chooseButtonOutlet.titleLabel?.adjustsFontSizeToFitWidth = true

        chooseButtonOutlet.titleLabel?.minimumScaleFactor = 0.5
        // Do any additional setup after loading the view.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AppData.schoolsNew.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let school = AppData.schoolsNew[indexPath.row].full
        cell.textLabel?.text = school
        cell.detailTextLabel?.text = AppData.schoolsNew[indexPath.row].inits
        
        for sch in selectedSchools{
            if sch.full == school{
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition(rawValue: 0) ?? .top)
                
            }
        }
        
        // highlighting previous selected schools
//        if selectedMeet?.schools[school] != nil{
//            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition(rawValue: 0) ?? .top)
//           
//        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedSchools.removeAll { (school) -> Bool in
            school.full == AppData.schoolsNew[indexPath.row].full
        }
    }
    
    func getSchools(){
        if let selectedPaths = tableViewOutlet.indexPathsForSelectedRows{
                          //print(selectedPaths)
                        selectedSchools = [School]()
                          for path in selectedPaths{
                            selectedSchools.append(AppData.schoolsNew[path.row])
                            
//                            let selectedSchoolKey = schoolKeys[path.row]
//                            selectedSchools[selectedSchoolKey] = AppData.schools[selectedSchoolKey]
                          }
                      }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        getSchools()
        
    }
    
}
