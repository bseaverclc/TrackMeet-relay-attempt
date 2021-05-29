//
//  School.swift
//  TrackMeet
//
//  Created by Brian Seaver on 4/2/21.
//  Copyright © 2021 clc.seaver. All rights reserved.
//

import Foundation
import Firebase

public class School: Codable{
    var full: String
    var inits: String
    var coaches = [String]()
    var uid: String?
    
    init(full: String, inits: String) {
        self.full = full
        self.inits = inits
        
    }
    
    init(key: String, dict: [String:Any]  ){
        uid = key
        full = dict["full"] as! String
        inits = dict["inits"] as! String
        
        //levels = [String]()
        if let coachesArray = dict["coaches"] as? NSArray{
        for i in 0..<coachesArray.count{
            coaches.append(coachesArray[i] as! String)
        }
        }
        
    }
    
    func addCoach(email: String){
        coaches.append(email)
        
    }
    
    func deleteFromFirebase(){
        if let ui = uid{
        Database.database().reference().child("schoolsNew").child(ui).removeValue()
        print("schoolnew has been removed from Firebase")
        }
        else{
            print("Error Deleting schoolnew")
        }
    }
    
    func updateFirebase(){
        let ref = Database.database().reference().child("schoolsNew").child(uid!)
        let dict = ["full": self.full, "inits":self.inits, "coaches": coaches] as [String : Any]
            ref.updateChildValues(dict)
        
    }
    
    func saveToFirebase(){
        let ref = Database.database().reference()
       
        let dict = ["full": self.full, "inits":self.inits, "coaches": coaches] as [String : Any]
       
        
        let thisUserRef = ref.child("schoolsNew").childByAutoId()
        uid = thisUserRef.key
        thisUserRef.setValue(dict)
    
        // Don't need, bercause above dict works
//        for c in coaches{
//            let emails = ["email": c] as [String : Any]
//            let coachID = thisUserRef.child("coaches").childByAutoId()
//            //uid = eventsID.key
//            coachID.setValue(emails)
//            
//        }
    }
    
}
