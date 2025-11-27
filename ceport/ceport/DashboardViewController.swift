//
//  DashboardViewController.swift
//  ceport
//
//  Created by mac on 26/11/25.
//

import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var labelWelcome: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    
    @IBOutlet weak var labelAirQuality: UILabel!
    @IBOutlet weak var buttonAirQuality: UIButton!
    
    @IBOutlet weak var labelHumidity: UILabel!
    @IBOutlet weak var labelTemperature: UILabel!
    
    @IBOutlet weak var labelNoiseLevel: UILabel!
    @IBOutlet weak var buttonNoiseLevel: UIButton!
    
    @IBOutlet weak var buttonTransit: UIButton!
    
    @IBOutlet weak var labelSystemStatusDescription: UILabel!
    @IBOutlet weak var labelStatusUpdate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
