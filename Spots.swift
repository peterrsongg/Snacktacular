//
//  Spots.swift
//  Snacktacular
//
//  Created by Peter Song  on 11/5/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Spots{
    var spotArray = [Spot]()
    var db: Firestore!
    
    init (){
        db = Firestore.firestore()
    }
    func loadData(completed: @escaping () -> () ){
        db.collection("spots").addSnapshotListener { (querySnaphot, error) in
            guard error == nil else{
                print ("*** Error adding the snapshot listener")
                return completed()
            }
        self.spotArray = []
        
            for document in querySnaphot!.documents {
            let spot = Spot(dictionary: document.data())
            spot.documentID = document.documentID
            self.spotArray.append(spot)
        }
        completed()
    }
}
}
