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
    
    var currentUser: User?
    
    @IBOutlet weak var labelAirQuality: UILabel!
    @IBOutlet weak var buttonAirQuality: UIButton!
    
    @IBOutlet weak var labelHumidity: UILabel!
    @IBOutlet weak var labelTemperature: UILabel!
    
    @IBOutlet weak var labelNoiseLevel: UILabel!
    @IBOutlet weak var buttonNoiseLevel: UIButton!
    
    @IBOutlet weak var buttonTransit: UIButton!
    
    @IBOutlet weak var labelSystemStatusDescription: UILabel!
    @IBOutlet weak var labelStatusUpdate: UILabel!
    
    // Timer to update data every minute
    var updateTimer: Timer?
    var secondsCounter: Timer?
    var secondsSinceUpdate: Int = 0
    
    // Colors
    let colorGood = UIColor(red: 0xA8/255.0, green: 0xFB/255.0, blue: 0xCE/255.0, alpha: 1.0) // #A8FBCE
    let colorModerate = UIColor(red: 0xF7/255.0, green: 0xFB/255.0, blue: 0xA8/255.0, alpha: 1.0) // #F7FBA8
    let colorBad = UIColor(red: 0xFB/255.0, green: 0xA8/255.0, blue: 0xA8/255.0, alpha: 1.0) // #FBA8A8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set welcome message
        labelWelcome.text = "Bienvenido"

        // Initial data fetch
        fetchSensorData()
        
        // Timer to fetch data every minute (60 seconds)
        updateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(fetchSensorData), userInfo: nil, repeats: true)
        
        // Timer to update seconds counter every second
        secondsCounter = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSecondsCounter), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop timers when leaving the view
        updateTimer?.invalidate()
        updateTimer = nil
        secondsCounter?.invalidate()
        secondsCounter = nil
    }
    
    // Fetch sensor data from API
    @objc func fetchSensorData() {
        SensorService.shared.getLastSensorReading { sensor, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Error - show error message
                    self.showErrorState(message: error)
                } else if let sensor = sensor {
                    // Success - update UI with sensor data
                    self.updateUI(with: sensor)
                    self.secondsSinceUpdate = 0
                    self.updateStatusLabel()
                } else {
                    self.showErrorState(message: "No hay datos disponibles")
                }
            }
        }
    }
    
    // Update UI with sensor data
    func updateUI(with sensor: Sensor) {
        // Show status labels
        labelSystemStatusDescription.text = "Sensores monitoreando correctamente"
        labelStatusUpdate.isHidden = false
        
        // Air Quality (Gas01)
        let gasValue = sensor.gas01 ?? 0
        updateAirQuality(value: gasValue)
        
        // Temperature (Tem01)
        let temperature = sensor.tem01 ?? 0
        labelTemperature.text = String(format: "%.1f°C", temperature)
        
        // Humidity (Hum01)
        let humidity = sensor.hum01 ?? 0
        labelHumidity.text = String(format: "Humedad: %.0f%%", humidity)
        
        // Noise Level (Son01)
        let noiseLevel = sensor.son01 ?? 0
        updateNoiseLevel(value: noiseLevel)
        
        // Transit (Ult01 and Ult02)
        let ult01 = Int(sensor.ult01 ?? 0)
        let ult02 = Int(sensor.ult02 ?? 0)
        updateTransit(ult01: ult01, ult02: ult02)
    }
    
    // Update Air Quality
    func updateAirQuality(value: Int) {
        labelAirQuality.text = "\(value)"
        
        if value < 500 {
            // Good air quality
            buttonAirQuality.setTitle("Calidad Buena", for: .normal)
            buttonAirQuality.backgroundColor = colorGood
        } else if value < 1000 {
            // Moderate air quality
            buttonAirQuality.setTitle("Calidad Moderada", for: .normal)
            buttonAirQuality.backgroundColor = colorModerate
        } else {
            // Bad air quality
            buttonAirQuality.setTitle("Mala Calidad", for: .normal)
            buttonAirQuality.backgroundColor = colorBad
        }
    }
    
    // Update Noise Level
    func updateNoiseLevel(value: Int) {
        labelNoiseLevel.text = "\(value)"
        
        if value < 40 {
            // Low noise
            buttonNoiseLevel.setTitle("Ruido Bajo", for: .normal)
            buttonNoiseLevel.backgroundColor = colorGood
        } else if value < 70 {
            // Moderate noise
            buttonNoiseLevel.setTitle("Ruido Moderado", for: .normal)
            buttonNoiseLevel.backgroundColor = colorModerate
        } else {
            // High noise
            buttonNoiseLevel.setTitle("Ruido Alto", for: .normal)
            buttonNoiseLevel.backgroundColor = colorBad
        }
    }
    
    // Update Transit based on parking spots
    func updateTransit(ult01: Int, ult02: Int) {
        let occupiedSpots = (ult01 == 1 ? 1 : 0) + (ult02 == 1 ? 1 : 0)
        
        if occupiedSpots == 0 {
            // Low transit - no spots occupied
            buttonTransit.setTitle("Tránsito Bajo", for: .normal)
            buttonTransit.backgroundColor = colorGood
        } else if occupiedSpots == 1 {
            // Moderate transit - one spot occupied
            buttonTransit.setTitle("Tránsito Moderado", for: .normal)
            buttonTransit.backgroundColor = colorModerate
        } else {
            // High transit - both spots occupied
            buttonTransit.setTitle("Tránsito Alto", for: .normal)
            buttonTransit.backgroundColor = colorBad
        }
    }
    
    // Show error state
    func showErrorState(message: String) {
        labelSystemStatusDescription.text = "Los sensores no se están monitoreando"
        labelStatusUpdate.isHidden = true
        
        // Set default values
        labelAirQuality.text = "Calidad del aire: --"
        buttonAirQuality.setTitle("Sin datos", for: .normal)
        buttonAirQuality.backgroundColor = .lightGray
        
        labelTemperature.text = "--°C"
        labelHumidity.text = "Humedad: --%"
        
        labelNoiseLevel.text = "Nivel de ruido: -- dB"
        buttonNoiseLevel.setTitle("Sin datos", for: .normal)
        buttonNoiseLevel.backgroundColor = .lightGray
        
        buttonTransit.setTitle("Sin datos", for: .normal)
        buttonTransit.backgroundColor = .lightGray
    }
    
    // Update seconds counter
    @objc func updateSecondsCounter() {
        secondsSinceUpdate += 1
        updateStatusLabel()
    }
    
    // Update status label with time
    func updateStatusLabel() {
        if secondsSinceUpdate == 0 {
            labelStatusUpdate.text = "Última actualización: Ahora"
        } else if secondsSinceUpdate == 1 {
            labelStatusUpdate.text = "Última actualización: 1 segundo"
        } else if secondsSinceUpdate < 60 {
            labelStatusUpdate.text = "Última actualización: \(secondsSinceUpdate) segundos"
        } else {
            let minutes = secondsSinceUpdate / 60
            if minutes == 1 {
                labelStatusUpdate.text = "Última actualización: 1 minuto"
            } else {
                labelStatusUpdate.text = "Última actualización: \(minutes) minutos"
            }
        }
    }
    
    // Back button action
    @IBAction func backButtonTapped(_ sender: UIButton) {
        // Dismiss the current view controller
        dismiss(animated: true, completion: nil)
    }
}
