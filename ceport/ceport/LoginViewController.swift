//
//  LoginViewController.swift
//  ceport
//
//  Created by mac on 26/11/25.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var labelUserInput: UITextField!
    
    @IBOutlet weak var labelPasswordInput: UITextField!
    
    // Store the logged in user
    var loggedInUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    // MARK: - Navigation

    // Prepare data before navigating to next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check if this is the arrow0 segue to ParkingViewController
        if segue.identifier == "arrow0" {
            // Get the destination view controller
            if let parkingVC = segue.destination as? ParkingViewController {
                // Pass the user data
                parkingVC.currentUser = self.loggedInUser
            }
        }
    }
    
    @IBAction func buttonContinue(_ sender: UIButton) {
        // Get email and password from text fields
        guard let email = labelUserInput.text, !email.isEmpty else {
            showAlert(message: "Please enter your email")
            return
        }
        
        guard let password = labelPasswordInput.text, !password.isEmpty else {
            showAlert(message: "Please enter your password")
            return
        }
        
        // Show loading (you can add an activity indicator here if you want)
        print("Logging in...")
        
        // Call the login service
        AuthService.shared.login(email: email, password: password) { user, error in
            // This runs on background thread, switch to main thread for UI updates
            DispatchQueue.main.async {
                if let error = error {
                    // Login failed - show error
                    self.showAlert(message: error)
                } else if let user = user {
                    // Login successful - store user and navigate
                    self.loggedInUser = user
                    print("Login successful: \(user.email)")
                    
                    // Perform the segue to ParkingViewController
                    self.performSegue(withIdentifier: "arrow0", sender: self)
                }
            }
        }
    }
    
    // Helper function to show alerts
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Login", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
