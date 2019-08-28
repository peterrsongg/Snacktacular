//
//  ViewController.swift
//  Snacktacular
//
//  Created by John Gallaugher on 3/23/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseUI
import GoogleSignIn


class SpotsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var spots: Spots!
    var authUI: FUIAuth!
    var locationManager: CLLocationManager!
    var currentLocation : CLLocation!
    var snackUser: SnackUser!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
//        let db = Firestore.firestore()
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings
        super.viewDidLoad()
        authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        spots = Spots()

    }
    override func viewWillAppear( _ animated: Bool){
        getLocation()
        navigationController?.setToolbarHidden(false, animated: false)
        spots.loadData
            {
                self.sortBasedOnSegmentedPressed()
                self.tableView.reloadData()
            
        }
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "ShowSpot"{
            let destination = segue.destination as! SpotDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.spot = spots.spotArray[selectedIndexPath.row]
            
        }else{
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    func signIn(){
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            ]
        let currentUser = authUI.auth?.currentUser
        if authUI.auth?.currentUser == nil{
            self.authUI.providers = providers
            present(authUI.authViewController(), animated: true , completion: nil )
        }else{
            tableView.isHidden = false
            snackUser = SnackUser(user: currentUser!)
            snackUser.saveIfNewUser()
        }
        
    }
    func showAlert(title:String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController,animated: true, completion: nil)
    }
    func sortBasedOnSegmentedPressed(){
        switch sortSegmentedControl.selectedSegmentIndex{
        case 0:// A-Z
            spots.spotArray.sort(by:{$0.name < $1.name})
        case 1: // Closest
            spots.spotArray.sort(by: {$0.Location.distance(from: currentLocation) < $1.Location.distance(from: currentLocation)})
            
        case 2: //Avg Rating
            print("TODO")
        default:
            print("**** Error, hey you should have gotten here, our segmented control should just have 3 segments.")
        }
        tableView.reloadData()
    }
    @IBAction func sortSegmentedPressed(_ sender: Any) {
        sortBasedOnSegmentedPressed()
    }
    
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI!.signOut()
            print("^^^ Successfully signed out!")
            signIn()
            tableView.isHidden = true

        }catch{
            print("*** Error Couldn't sign out!")
            tableView.isHidden = true

        }
    }
}



extension SpotsListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.spotArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SpotsTableViewCell
        if let currentLocation = currentLocation {
            cell.currentLocation = currentLocation
        }
        cell.configureCell(spot: spots.spotArray[indexPath.row])
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
extension SpotsListViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            tableView.isHidden = false

            print("*** We signed in with the user \(user.email ?? "unknown email")")
        }
    }
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let loginViewController  = FUIAuthPickerViewController(authUI: authUI)
        loginViewController.view.backgroundColor = UIColor.white
        
        let marginInsets: CGFloat = 16
        let imageHeight: CGFloat = 225
        let imageY = self.view.center.y - imageHeight
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width:self.view.frame.width - (marginInsets*2), height: imageHeight)
        let logoImageView = UIImageView(frame:logoFrame)
        logoImageView.image = UIImage(named:"logo")
        logoImageView.contentMode = .scaleAspectFit
        loginViewController.view.addSubview(logoImageView)
        
        return loginViewController
    }
}
extension SpotsListViewController: CLLocationManagerDelegate{
    
    func getLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus){
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Open the Settings app > Privacy > Location Services > WeatherGift to enable location services in this app.")
        case .restricted:
            showAlert(title: "Location Services Denied", message: "It may be that parental controls are restricting location use in thhis app")
        }
        
    }
    func showAlertToPrivacySettings(title:String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString)else{
            return
        }
        
        let settingsActions = UIAlertAction(title: "Settings", style: .default)
        { value in UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)}
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel
            , handler:  nil)
        alertController.addAction(settingsActions)
        alertController.addAction(cancelAction)
        present(alertController,animated: true, completion: nil)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        print("Current Location  = \(currentLocation.coordinate.longitude), \(currentLocation.coordinate.latitude)")
        sortBasedOnSegmentedPressed()
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location.")
    }
}

