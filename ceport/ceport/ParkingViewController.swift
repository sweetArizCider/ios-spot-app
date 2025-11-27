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
      
      // Timer to check sensor data every minute
      var updateTimer: Timer?
      
      // Colors
      let colorFree = UIColor(red: 0xA8/255.0, green: 0xFB/255.0, blue: 0xCE/255.0, alpha: 1.0) // #A8FBCE
      let colorOccupied = UIColor(red: 0x3F/255.0, green: 0x50/255.0, blue: 0x4A/255.0, alpha: 1.0) // #3F504A
      let colorInactive = UIColor(red: 0xF6/255.0, green: 0xF6/255.0, blue: 0xF6/255.0, alpha: 1.0) // #F6F6F6
      
      override func viewDidLoad() {
          super.viewDidLoad()

          // Print user info for testing
          if let user = currentUser {
              print("Welcome to Parking: \(user.email)")
              if let name = user.name {
                  print("User name: \(name)")
              }
          }
          
          // Initial check
          checkSensorStatusAndData()
          
          // Start timer to check every minute (60 seconds)
          updateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(checkSensorStatusAndData), userInfo: nil, repeats: true)
      }
      
      override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          // Stop timer when leaving the view
          updateTimer?.invalidate()
          updateTimer = nil
      }
      
      // Check sensor status and update UI
      @objc func checkSensorStatusAndData() {
          // Check Ult01 status
          SensorService.shared.getSensorStatus(sensorName: .ult01) { status, error in
              if let status = status {
                  DispatchQueue.main.async {
                      if status.isActive {
                          // Sensor is active, check actual data
                          self.checkSpotData(spotButton: self.buttonSpot0, sensorKey: "Ult01")
                      } else {
                          // Sensor is inactive - gray background
                          self.buttonSpot0.backgroundColor = self.colorInactive
                      }
                  }
              }
          }
          
          // Check Ult02 status
          SensorService.shared.getSensorStatus(sensorName: .ult02) { status, error in
              if let status = status {
                  DispatchQueue.main.async {
                      if status.isActive {
                          // Sensor is active, check actual data
                          self.checkSpotData(spotButton: self.buttonSpot1, sensorKey: "Ult02")
                      } else {
                          // Sensor is inactive - gray background
                          self.buttonSpot1.backgroundColor = self.colorInactive
                      }
                  }
              }
          }
      }
      
      // Check spot data from sensor reading
      func checkSpotData(spotButton: UIButton, sensorKey: String) {
          SensorService.shared.getLastSensorReading { sensor, error in
              if let sensor = sensor {
                  DispatchQueue.main.async {
                      var value = 0
                      
                      // Get the appropriate sensor value
                      if sensorKey == "Ult01" {
                          value = Int(sensor.ult01 ?? 0)
                      } else if sensorKey == "Ult02" {
                          value = Int(sensor.ult02 ?? 0)
                      }
                      
                      // 0 = free (green), 1 = occupied (dark)
                      if value == 0 {
                          spotButton.backgroundColor = self.colorFree
                      } else {
                          spotButton.backgroundColor = self.colorOccupied
                      }
                  }
              }
          }
      }
      
      // Spot 0 button action (Ult01)
      @IBAction func spotAction0(_ sender: UIButton) {
          handleSpotTap(sensorName: .ult01, spotNumber: "0")
      }
      
      // Spot 1 button action (Ult02)
      @IBAction func spotAction1(_ sender: UIButton) {
          handleSpotTap(sensorName: .ult02, spotNumber: "1")
      }
      
      // Handle spot button tap
      func handleSpotTap(sensorName: SensorName, spotNumber: String) {
          // Get current sensor status
          SensorService.shared.getSensorStatus(sensorName: sensorName) { status, error in
              guard let status = status else {
                  DispatchQueue.main.async {
                      self.showAlert(title: "Error", message: error ?? "Failed to get sensor status")
                  }
                  return
              }
              
              DispatchQueue.main.async {
                  // Show confirmation dialog
                  let action = status.isActive ? "deactivate" : "activate"
                  let message = "Do you want to \(action) spot \(spotNumber)?"
                  
                  let alert = UIAlertController(title: "Spot \(spotNumber)", message: message, preferredStyle: .alert)
                  
                  // Confirm button
                  alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                      if status.isActive {
                          // Deactivate sensor
                          self.deactivateSensor(sensorName: sensorName, spotNumber: spotNumber)
                      } else {
                          // Activate sensor
                          self.activateSensor(sensorName: sensorName, spotNumber: spotNumber)
                      }
                  })
                  
                  // Cancel button
                  alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                  
                  self.present(alert, animated: true)
              }
          }
      }
      
      // Activate sensor
      func activateSensor(sensorName: SensorName, spotNumber: String) {
          SensorService.shared.activateSensor(sensorName: sensorName) { status, error in
              DispatchQueue.main.async {
                  if let error = error {
                      self.showAlert(title: "Error", message: error)
                  } else {
                      self.showAlert(title: "Success", message: "Spot \(spotNumber) activated")
                      // Refresh the UI
                      self.checkSensorStatusAndData()
                  }
              }
          }
      }
      
      // Deactivate sensor
      func deactivateSensor(sensorName: SensorName, spotNumber: String) {
          SensorService.shared.deactivateSensor(sensorName: sensorName) { status, error in
              DispatchQueue.main.async {
                  if let error = error {
                      self.showAlert(title: "Error", message: error)
                  } else {
                      self.showAlert(title: "Success", message: "Spot \(spotNumber) deactivated")
                      // Refresh the UI
                      self.checkSensorStatusAndData()
                  }
              }
          }
      }
      
      // Show alert helper
      func showAlert(title: String, message: String) {
          let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
      }
      
  }
