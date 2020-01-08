//
//  FaceIdVC.swift
//  ADA
//
//  Created by Azmi Muhammad on 18/09/19.
//  Copyright © 2019 Azmi Muhammad. All rights reserved.
//

import UIKit
import LocalAuthentication

class FaceIdVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var context: LAContext = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }

    @IBAction func onFaceIDTapped(_ sender: UIButton) {
        context.localizedCancelTitle = "Cancel"
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Log in to your account"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                if success {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {return}
                        self.moveToLocation()
                    }
                } else {
                    print(error?.localizedDescription ?? "Can't evaluate policy")
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {return}
                        self.updateUI()
                    }
                }
            }
        }
    }
    
    private func moveToLocation() {
        Preference.set(value: true, forKey: .kFaceId)
        let vc = LocationVC()
        present(vc, animated: true, completion: nil)
    }
    
    private func updateUI() {
        imageView.image = UIImage(named: "ic_surpised")
        infoLabel.text = "Your device seems not recognizing you. Try again"
    }
}
