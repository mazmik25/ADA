//
//  HomeVC.swift
//  ADA
//
//  Created by Azmi Muhammad on 18/09/19.
//  Copyright © 2019 Azmi Muhammad. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class HomeVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var interactionView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var findMeButton: UIButton!
    var locationManager : CLLocationManager = CLLocationManager()
    var db: Locations!
    var location: CLLocationCoordinate2D?
    var users: [Users]?
    var region: CLCircularRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissInteractionView)))
        setupLocationManager()
        interactionView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Find Friends"
        setupRightButton()
    }
    
    @objc private func dismissInteractionView() {
        interactionView.isHidden = true
    }
    
    private func setupRightButton() {
        let profile: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_profile"), style: .plain, target: self, action: #selector(moveToProfile))
        let chat: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_chat"), style: .plain, target: self, action: #selector(moveToChat))
        navigationItem.rightBarButtonItems = [chat, profile]
    }
    
    @objc private func moveToProfile() {
        navigationController?.pushViewController(ProfileVC(), animated: true)
    }
    
    @objc private func moveToChat() {
        navigationController?.pushViewController(ChatVC(), animated: true)
    }
    
    @IBAction func findMeTapped(_ sender: UIButton) {
        guard let coordinate = location, let users = users else {return}
        
        if region.contains(coordinate) {
            let friend = users.filter { (user) -> Bool in
                return user.name == self.nameLabel.text
            }
            pushNotification(user: friend[0])
        } else {
            createAlert(msg: "You are far away from your friend")
        }
    }
    
    private func pushNotification(user: Users) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.findMe(uuid: user.uuid) { [weak self] (_ , error) in
            guard let self = self else { return }
            if let err = error {
                print(err)
            } else {
                self.createNewFriend(uuid: user.uuid)
            }
            
        }
    }
    
    private func createNewFriend(uuid: String) {
        DispatchQueue.main.async {
            let database = BaseDatabase(key: .Friends)
            let friend = Friends(uuid: UUID().uuidString, friendUuid: uuid)
            database.save(model: friend) { (err) in
                if let err = err {
                    print(err)
                } else {
                    self.createAlert(msg: "You just add a friend")
                }
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    private func createAlert(msg: String) {
        let alert = UIAlertController(title: "Information", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            setupMapView(initialLocation: location.coordinate)
            setupGeofencing(initialLocation: location.coordinate)
            retrieveLocations()
            updateLocation(coordinate: location.coordinate)
        }
    }
}

extension HomeVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        interactionView.isHidden = false
        guard let name = view.annotation?.title as? String, let coordinate = view.annotation?.coordinate, !name.elementsEqual("My Location") else { return }
        nameLabel.text = name
        location = coordinate
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
        overlayRenderer.lineWidth = 2.0
        overlayRenderer.strokeColor = UIColor(string: "#141414").withAlphaComponent(0.1)
        overlayRenderer.fillColor = UIColor(string: "#141414").withAlphaComponent(0.1)
        return overlayRenderer
    }
    
    private func setupMapView(initialLocation: CLLocationCoordinate2D) {
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let mapRegion = MKCoordinateRegion(center: initialLocation, span: span)
        mapView.setRegion(mapRegion, animated: true)
        
        mapView.removeOverlays(mapView.overlays)
        let regionCircle = MKCircle(center: initialLocation, radius: 100)
        mapView.addOverlay(regionCircle)
        mapView.showsUserLocation = true
    }
    
    private func setupGeofencing(initialLocation: CLLocationCoordinate2D) {
        region = CLCircularRegion(center: initialLocation, radius: 100, identifier: "ADA")
        region.notifyOnExit = true
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
    }
    
    private func addPinInMap() {
        guard let users = users else {return}
        users.forEach { (user) in
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: user.lat, longitude: user.long)
            annotation.coordinate = coordinate
            annotation.title = user.name
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
}

extension HomeVC {
    private func retrieveLocations() {
        db = Locations(key: .Profile)
        db.retrieveLocation { [weak self] (results, err) in
            guard let data = results, let self = self else { return print(err) }
            self.users = data
            self.addPinInMap()
        }
    }
    
    private func updateLocation(coordinate: CLLocationCoordinate2D) {
        db.updateLocation(coordinate: coordinate) { (err) in
            if let err = err {
                print(err)
            }
        }
    }
}
