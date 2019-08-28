//
//  ReviewTableViewController.swift
//  Snacktacular
//
//  Created by Peter Song  on 11/21/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import UIKit
import Firebase

class ReviewTableViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet var starButtonCollection: [UIButton]!
    
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var reviewTitleField: UITextField!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelBarButton:UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var buttonsBackgroundView: UIView!
    var spot: Spot!
    var review: Review!
    let dateFormatter = DateFormatter()
    var rating = 0 {
        didSet {
            for starButton in starButtonCollection{
                let image = UIImage(named: (starButton.tag < rating ? "star-filled" : "star-empty"))
                starButton.setImage(image, for: .normal)
                
            }
            review.rating = rating
            print(">>> NEW rating \(rating)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        guard spot != nil else {
            print("*** ERROR: did not have a valid Spot in ReviewDetailViewController.")
            return
        }

        
        if review == nil {
            review = Review()
        }
        updateUserInterface()

       
    }
    func updateUserInterface(){
        nameLabel.text = spot.name
        addressLabel.text = spot.address
        rating = review.rating
        reviewTitleField.text = review.title
        enableDisableSaveButton()
        reviewTextView.text = review.title
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        reviewDateLabel.text = "posted: \(dateFormatter.string(from:review.date))"
        if review.documentID == "" {//This is a new review
            addBordersToEditableObjects()
    } else{
            if review.reviewUserID == Auth.auth().currentUser?.email{ // This review was posted by current User
            self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBordersToEditableObjects()
                deleteButton.isHidden = false
            }else{ // this review was posted by anotheruser
                cancelBarButton.title = ""
                saveBarButton.title = ""
                postedByLabel.text = "Posted by: \(review.reviewUserID)"
                for starButton in starButtonCollection{
                    starButton.backgroundColor = UIColor.white
                    starButton.adjustsImageWhenDisabled = false
                    starButton.isEnabled = false
                    reviewTitleField.isEnabled = false
                    reviewTextView.isEditable = false
                    reviewTitleField.backgroundColor = UIColor.white
                    reviewTextView.backgroundColor = UIColor.white
                    
                    
                }
            }
            
        }
    }
    func addBordersToEditableObjects(){
        reviewTitleField.addBorder(width: 0.5, radius: 5.0, color: .black)
        reviewTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
        buttonsBackgroundView.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    func enableDisableSaveButton(){
        if reviewTitleField.text != ""{
            saveBarButton.isEnabled = true
        }else{
            saveBarButton.isEnabled = false
        }
    }
    func saveThenSegue(){
        review.title = reviewTitleField.text!
        review.text = reviewTextView.text!
        review.saveData(spot: spot) { (success) in
            if success{
                self.leaveViewController()
            }else{
                print("**** ERROR: Couldn't leave this view controller becuase the data wasn't saved")
            }
        }
    }
    func leaveViewController(){
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func starButtonPressed(_ sender: UIButton) {
        rating  = Int(sender.tag + 1 ) // add one since we're zero indexed
    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        saveThenSegue()

        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
        
    }

    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        review.deleteData(spot: spot) { (success) in
            if success{
                self.leaveViewController()
            } else{
                print("ERROR: Delete Unsuccessful")
            }
        }
    }
    
    @IBAction func reviewTitleChanged(_ sender: Any) {
        enableDisableSaveButton()
    }
    
    @IBAction func returnTitleDonePressed(_ sender: Any) {
        saveThenSegue()
        
    }
    




}
