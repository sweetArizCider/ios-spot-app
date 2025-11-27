//
//  ParkingViewController.swift
//  ceport
//
//  Created by mac on 26/11/25.
//

import UIKit

class ParkingViewController: UIViewController {

    @IBOutlet weak var buttonSpot0: UIButton!
    @IBOutlet weak var buttonSpot1: UIButton!
    
    // User data received from login
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Print user info for testing
        if let user = currentUser {
            print("Welcome to Parking: \(user.email)")
            if let name = user.name {
                print("User name: \(name)")
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
