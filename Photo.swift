//
//  Photo.swift
//  Snacktacular
//
//  Created by Peter Song  on 11/22/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var postedBy: String
    var date: Date
    var documentUUID: String // Universal Unique Identifier
    var dictionary: [String:Any]{
        return ["description" : description, "postedBy" : postedBy, "date" : date]
    }
    
    init(image: UIImage, description: String, postedBy: String, date: Date, documentUUID: String){
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentUUID = documentUUID

    }
    convenience init(){
        let postedBy = Auth.auth().currentUser?.email ?? "unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentUUID: "")
    }
    convenience init(dictionary: [String: Any]){
        
        let description = dictionary["title"] as! String? ?? ""
        let postedBy = dictionary["text"] as! String? ?? ""
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(image: UIImage(), description: description, postedBy: postedBy, date: date, documentUUID: "")
    }
    func saveData(spot: Spot, completed: @escaping (Bool)->() ){
        let db = Firestore.firestore()
        let storage = Storage.storage()
        //convert photo.image to a Data type so it can be saved by Firebase Storage
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else{
            print("*** ERROR: could not convert image to data format")
            return completed(false)
        }
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        documentUUID = UUID().uuidString // generate a unique ID to use for the photo image's name
        // create a ref to upload storage to spo.documentID's folder(bucket) with theh name we created.
        let storageRef = storage.reference().child(spot.documentID).child(self.documentUUID)
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetadata){
            
            metadata, error in
            guard error == nil else{
                print("ERROR during .putdata storage upload for reference \(storageRef). Error: \(error!.localizedDescription)")
                return
            }
            print("noice upload worked! Metadata is \(metadata)")
        }
        
        uploadTask.observe(.success){(snapshot) in
            let dataToSave = self.dictionary
            //This will eithher create a new doc at document UUID or update the existing doc with that name
            
            let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentUUID)
            ref.setData(dataToSave){ (error) in
                
                if let error = error {
                    print("Error updating document \(self.documentUUID) in spot \(spot.documentID)")
                    completed(false)
                    
                }else{
                    print("Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
            
        }
        uploadTask.observe(.failure){(snapshot) in
            if let error = snapshot.error{
                print("*** ERROR: upload task for file \(self.documentUUID) failed, in spot \(spot.documentID)")
            }
            return completed(false)
        }
        //create Dictionary represeting the data to save

        }
    }
