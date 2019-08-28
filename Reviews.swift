//
//  Reviews.swift
//  Snacktacular
//
//  Created by Peter Song  on 11/22/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Reviews{
    var reviewArray: [Review] = []
    var db: Firestore!
    init() {
        db = Firestore.firestore()
    }
    func loadData(spot: Spot, completed: @escaping () -> () ){
        guard spot.documentID != "" else{
            return
        }
        db.collection("spots").document(spot.documentID).collection("reviews").addSnapshotListener { (querySnaphot, error) in
            guard error == nil else{
                print ("*** Error adding the snapshot listener")
                return completed()
            }
            self.reviewArray = []
            
            for document in querySnaphot!.documents {
                let review = Review(dictionary: document.data())
                review.documentID = document.documentID
                self.reviewArray.append(review)
            }
            completed()
        }
    }
}
