//
//  Review.swift
//  Snacktacular
//
//  Created by Peter Song  on 11/22/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any]{
        return ["title" : title, "text" : text, "rating": rating, "reviewUserID":reviewUserID,"date":Date(),"documentID":documentID]
    }

    
    init (title: String, text: String,rating: Int, reviewUserID: String, date: Date, documentID: String){
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewUserID = reviewUserID
        self.date = date
        self.documentID = documentID
        
    }
    convenience init(dictionary: [String: Any]){
        
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewUserID = dictionary["reviewUserID"] as! String? ?? ""
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(title: title, text: text, rating: rating, reviewUserID: reviewUserID, date: date, documentID: "")
    }
    
    convenience init () {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        self.init(title: "", text: "", rating: 0, reviewUserID: currentUserID, date: Date(), documentID: "")
    }
    func saveData(spot: Spot, completed: @escaping (Bool)->() ){
        let db = Firestore.firestore()
        
        //create Dictionary represeting the data to save
        let dataToSave = self.dictionary
        //if we Have saved a record, we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave){ (error) in
                if let error = error {
                    print("Error updating document \(self.documentID) in spot \(spot.documentID)")
                    completed(false)
                    
                }else{
                    print("Document updated with ref ID \(ref.documentID)")
                    spot.updateAverageRating {
                        completed (true)
                    }
                }
            }
        }else {
            var ref: DocumentReference? = nil // let firestore create document id
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave){
                error in
                if let error = error {
                    print("Error creating new document in spot \(spot.documentID) for new review document ID \(error.localizedDescription)")
                    completed(false)
                    
                }else{
                    print("new document created with ref ID \(ref?.documentID ?? "unknown")")
                    spot.updateAverageRating {
                        completed (true)
                    }
                }
                
            }
        }
    }
    func deleteData(spot: Spot, completed: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentID).collection("reviews").document(documentID).delete()
            { error in

            if let error = error{
                print("*** ERROR deleting review document ID \(self.documentID) \(error.localizedDescription)")
                completed(false)
            }else{
                spot.updateAverageRating {
                    completed (true)
                }
                completed(true)
            }
        }
    }
}


