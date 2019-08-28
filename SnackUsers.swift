//
//  SnackUsers.swift
//  Snacktacular
//
//  Created by Peter Song  on 11/29/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class SnackUsers{
    var snackUserArray = [SnackUser]()
    var db: Firestore!
    
    init(){
        db = Firestore.firestore()
    }

    func loadData(completed: @escaping() -> ()){
        db.collection("users").addSnapshotListener{ (querySnapshot, error) in
            
            guard error == nil else{
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.snackUserArray = []
            // there are querySnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents{
                let snackUser = SnackUser(dictionary: document.data())
                snackUser.documentID = document.documentID
                self.snackUserArray.append(snackUser)
            }
            completed()
        }
    }
}
