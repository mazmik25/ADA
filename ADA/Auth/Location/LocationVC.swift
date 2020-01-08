//
//  LocationVC.swift
//  ADA
//
//  Created by Azmi Muhammad on 18/09/19.
//  Copyright © 2019 Azmi Muhammad. All rights reserved.
//

import UIKit
import CoreLocation

class LocationVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpNameAndEmail()
//        if let isAllowed = Preference.getBool(forKey: .kAccessLocation), isAllowed {
//            
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func onLocationPermissionTapped(_ sender: UIButton) {
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
    }
}

extension LocationVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            manager.requestWhenInUseAuthorization()
            updateUI(info: "Oops! We can’t find you. Allowing us to access your location will help us to find friends for you")
        case .authorizedWhenInUse:
            popUpNameAndEmail()
        case .authorizedAlways:
            popUpNameAndEmail()
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            updateUI(info: "Oops! We can’t find you. Allowing us to access your location will help us to find friends for you")
        case .denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            updateUI(info: "Oops! We can’t find you. Allowing us to access your location will help us to find friends for you")
        default:
            break
        }
        
    }
    
    private func popUpNameAndEmail() {
        Preference.set(value: true, forKey: .kAccessLocation)
        let alert = UIAlertController(title: "Basic Information", message: "Enter your name and your email", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            guard let nameField = alert.textFields?[0], let emailField = alert.textFields?[1] else {return}
            self.saveUser(name: nameField.text ?? "", email: emailField.text ?? "")
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func saveUser(name: String, email: String) {
        Preference.set(value: name, forKey: .kUserName)
        Preference.set(value: email, forKey: .kUserEmail)
        let db: Database = BaseDatabase(key: .Profile)
        let uuid: String = UUID().uuidString
        let user: User = User(email: email, name: name, dateOfBirth: "January 19, 1996", uuid: uuid, lat: -6.301595, long: 106.651958)
        db.save(model: user) { [weak self] (err) in
            guard let self = self else {return}
            self.handleDB(err: err)
        }
    }
    
    private func handleDB(err: Error?) {
        if let err = err {
            DispatchQueue.main.async {
                print(err)
                self.updateUI(info: "Our server run into a problem. We'll fix it for you later")
            }
        } else {
            DispatchQueue.main.async {
                self.moveToHome()
            }
        }
    }
    
    private func moveToHome() {
        let vc = HomeVC()
        
        let navController: UINavigationController = UINavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }
    
    private func updateUI(info: String, _ icon: String = "ic_surpised") {
        imageView.image = UIImage(named: icon)
        infoLabel.text = info
    }
}
