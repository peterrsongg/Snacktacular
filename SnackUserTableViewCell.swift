//
//  SnackUserTableViewCell.swift
//  Snacktacular
//
//  Created by Peter Song  on 11/29/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import UIKit
import SDWebImage

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class SnackUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var userSinceLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var snackUser: SnackUser! {
        didSet{
            
            photoImage.layer.cornerRadius = photoImage.frame.size.width / 2
            photoImage.clipsToBounds = true
            displayNameLabel.text = snackUser.displayName
            emailLabel.text = snackUser.email
            let formattedDate = dateFormatter.string(from: snackUser.userSince)
            userSinceLabel.text = "\(formattedDate)"
            
            guard let url = URL(string: snackUser.photoURL) else{
                photoImage.image = UIImage(named: "singleUser")
                print("ERROR: could not convert photoURL \(snackUser.photoURL) into a valid URL")
                return
            }
            photoImage.sd_setImage(with:url, placeholderImage: UIImage(named: "singleUser"))
        }
    }
}
