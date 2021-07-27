//
//  Athlete.swift
//  TrackMeet
//
//  Created by Brian Seaver on 5/17/20.
//  Copyright © 2020 clc.seaver. All rights reserved.
//

import Foundation
import FirebaseDatabase
enum levels{
    
}

public class Athlete : Codable{
    var first: String
    var last: String
    var school: String
    var schoolFull: String
    var grade: Int
    var events: [Event]
    var uid: String?
    
    init(f: String, l: String, s: String, g: Int, sf: String) {
        first = f
        last = l
        school = s
        grade = g
        events = [Event]()
        schoolFull = sf
       // saveToFirebase()
    }
    
    init(key: String, dict: [String:Any] ) {
        first = dict["first"] as! String
        last = dict["last"] as! String
        school = dict["school"] as! String
        grade = dict["grade"] as! Int
        events = [Event]()
        schoolFull = dict["schoolFull"] as! String
        uid = key
        //saveToFirebase()
    }
    
    init(id: String,f: String, l: String, s: String, g: Int, sf: String ) {
        first = f
        last = l
        school = s
        grade = g
        events = [Event]()
        schoolFull = sf
        uid = id
        //saveToFirebase()
    }
    
    // called when getting from firebase
    func addEvent(key: String, dict: [String:Any] ){
        events.append(Event(key: key, dict: dict))
    }
    
    func addEvent(e: Event){
        events.append(e)
        let ref = Database.database().reference().child(uid!)
        e.uid = ref.childByAutoId().key
        print("added event with key \(e.uid!)")
        updateFirebase()
    }
    
    func addEvent(name: String, level: String, meetName: String){
        let e = Event(name: name, level: level, meetName: meetName)
        events.append(e)
        let ref = Database.database().reference().child(uid!)
        e.uid = ref.childByAutoId().key
        print("added event with key \(e.uid!)")
        updateFirebase()
    }
    
    func getEvent(eventName: String, meetName: String) -> Event?{
        for e in events{
            if e.name == eventName && e.meetName == meetName{
                return e
            }
        }
        return nil
    }
    
    func equals(other: Athlete) -> Bool{
        if (self.first == other.first && self.last == other.last && self.schoolFull == other.schoolFull && self.grade == other.grade){
            return true
        }
        else{return false}
    }
    
    
    
    func saveToFirebase() {
        let ref = Database.database().reference()
       
        let dict = ["first": self.first, "last":self.last, "school": self.school, "schoolFull":self.schoolFull, "grade":self.grade] as [String : Any]
       
        
        let thisUserRef = ref.child("athletes").childByAutoId()
        uid = thisUserRef.key
        thisUserRef.setValue(dict)
        
        for e in events{
            let eventDict = ["meetName": e.meetName,"name": e.name, "level":e.level, "mark": e.mark, "markString": e.markString, "place":e.place ?? nil, "points": e.points, "heat": e.heat] as [String : Any]
            let eventsID = thisUserRef.child("events").childByAutoId()
            e.uid = eventsID.key
            eventsID.setValue(eventDict)
            
        }
     print("saving athlete to firebase")
     }
    
    func updateFirebase(){
        var ref = Database.database().reference().child("athletes").child(uid!)
        let dict = ["first": self.first, "last":self.last, "school": self.school, "schoolFull":self.schoolFull, "grade":self.grade] as [String : Any]
        
        ref.updateChildValues(dict)
        ref = ref.child("events")
        
        for e in events{
            let eventDict = ["meetName": e.meetName,"name": e.name, "level":e.level, "mark": e.mark, "markString": e.markString, "place":e.place ?? nil, "points": e.points, "heat": e.heat] as [String : Any]
            ref.child(e.uid!).updateChildValues(eventDict)
            if let rm = e.relayMembers{
                print("trying to update relayMembers in firebase")
                ref.child(e.uid!).updateChildValues(["relayMembers": rm])
                print("relay members updated in firebase")
                
            }
      
        }
        
        
        print("updating athlete in firebase")
}
    
    func addRelayMemberFirebase(member:Athlete){
        let dict = [member]
    }
    
    
   
    func deleteFromFirebase(){
        if let ui = uid{
        Database.database().reference().child("athletes").child(ui).removeValue()
        print("Athlete has been removed from Firebase")
        }
        else{
            print("Error Deleting Athlete! Athlete not in Firebase")
        }
    }
    
    func deleteEventFromFirebase(euid: String){
        if let uia = uid{
            
             Database.database().reference().child("athletes").child(uia).child("events").child(euid).removeValue()
            //print(ref)
        print("Event \(last) \(euid) has been removed from Firebase")
        }
        else{
            print("Error Deleting Event! Event not in Firebase")
        }
    }
    
    
}



public class Event:Codable{
    var name: String
    var level: String
    var mark: Float
    var markString: String
    var place: Int?
    var points = 0.0
    var heat = 0
    var meetName = ""
    var uid : String?
    var relayMembers : [String]?
    
    //build Event from Firebase
    init(key: String, dict: [String:Any] ) {
        uid = key
        name = dict["name"] as! String
        level = dict["level"] as! String
        if let m = dict["mark"]{
            mark = m as! Float;
        }
        else {mark = 0.0;}
        
        markString = dict["markString"] as! String
        if let p = dict["place"] as? Int{
        place = p
        }
        else{place = nil}
        points = dict["points"] as! Double
        if let heater = dict["heat"]{
            heat = heater as! Int
        }
        if let relay = dict["relayMembers"]{
            relayMembers = relay as? [String]
        }
       
        meetName = dict["meetName"] as! String
      
    }
    
    init(name: String, level: String, meetName: String) {
        self.name = name
        self.level = level
        self.mark = 0.0
        markString = ""
        self.meetName = meetName
        self.place = nil
        if name.contains("4x"){
            relayMembers = [String]()
        }
        
    }
    
    
    
}
