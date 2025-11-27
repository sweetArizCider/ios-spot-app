//
//  SensorService.swift
//  ceport
//
//  Created on 11/26/2025.
//

import Foundation

// Sensor reading data structure
struct Sensor: Codable {
    let id: String?
    let gas01: Int?        // Gas sensor
    let nfc01: String?     // NFC card UID
    let pir01: Int?        // Motion sensor (0 or 1)
    let hum01: Double?     // Humidity
    let ser01: Int?        // Servo position
    let son01: Int?        // Sound level
    let tem01: Double?     // Temperature
    let timestamp: String? // When data was recorded
    let ult01: Double?     // Ultrasonic sensor 1
    let ult02: Double?     // Ultrasonic sensor 2
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case gas01 = "Gas01"
        case nfc01 = "Nfc01"
        case pir01 = "Pir01"
        case hum01 = "Hum01"
        case ser01 = "Ser01"
        case son01 = "Son01"
        case tem01 = "Tem01"
        case timestamp
        case ult01 = "Ult01"
        case ult02 = "Ult02"
    }
}

// Sensor status (active/inactive)
struct SensorStatus: Codable {
    let name: String
    let isActive: Bool
}

// Available sensor names
enum SensorName: String {
    case gas01 = "Gas01"
    case hum01 = "Hum01"
    case pir01 = "Pir01"
    case ser01 = "Ser01"
    case son01 = "Son01"
    case tem01 = "Tem01"
    case ult01 = "Ult01"
    case ult02 = "Ult02"
    case nfc01 = "Nfc01"
}

// Class to handle sensor data and status
class SensorService: NSObject {
    // Shared instance to use throughout the app
    static let shared = SensorService()
    
    // API base URL
    private let baseURL = "https://ios-spot-nestjs-v1.vercel.app"
    
    private override init() {
        super.init()
    }
    
    // Get all sensor readings from the database
    func getAllSensors(completion: @escaping ([Sensor]?, String?) -> Void) {
        // Create the URL
        let urlString = "\(baseURL)/sensors"
        guard let url = URL(string: urlString) else {
            completion(nil, "Invalid URL")
            return
        }
        
        // Make the network call
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for network errors
            if let error = error {
                completion(nil, "Network error: \(error.localizedDescription)")
                return
            }
            
            // Check if we got data
            guard let data = data else {
                completion(nil, "No data received")
                return
            }
            
            // Parse the sensors
            if let sensors = try? JSONDecoder().decode([Sensor].self, from: data) {
                completion(sensors, nil)
            } else {
                completion(nil, "Failed to parse sensors")
            }
        }
        
        task.resume()
    }
    
    // Get only the most recent sensor reading
    func getLastSensorReading(completion: @escaping (Sensor?, String?) -> Void) {
        // Create the URL
        let urlString = "\(baseURL)/sensors/last"
        guard let url = URL(string: urlString) else {
            completion(nil, "Invalid URL")
            return
        }
        
        // Make the network call
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for network errors
            if let error = error {
                completion(nil, "Network error: \(error.localizedDescription)")
                return
            }
            
            // Check if we got data
            guard let data = data else {
                completion(nil, "No data received")
                return
            }
            
            // Parse the sensor
            if let sensor = try? JSONDecoder().decode(Sensor.self, from: data) {
                completion(sensor, nil)
            } else {
                completion(nil, "Failed to parse sensor data")
            }
        }
        
        task.resume()
    }
    
    // Get status of all sensors (active/inactive)
    func getAllSensorStatuses(completion: @escaping ([SensorStatus]?, String?) -> Void) {
        // Create the URL
        let urlString = "\(baseURL)/sensor-status"
        guard let url = URL(string: urlString) else {
            completion(nil, "Invalid URL")
            return
        }
        
        // Make the network call
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for network errors
            if let error = error {
                completion(nil, "Network error: \(error.localizedDescription)")
                return
            }
            
            // Check if we got data
            guard let data = data else {
                completion(nil, "No data received")
                return
            }
            
            // Parse the statuses
            if let statuses = try? JSONDecoder().decode([SensorStatus].self, from: data) {
                completion(statuses, nil)
            } else {
                completion(nil, "Failed to parse sensor statuses")
            }
        }
        
        task.resume()
    }
    
    // Get status of a specific sensor
    func getSensorStatus(sensorName: SensorName, completion: @escaping (SensorStatus?, String?) -> Void) {
        // Create the URL
        let urlString = "\(baseURL)/sensor-status/\(sensorName.rawValue)"
        guard let url = URL(string: urlString) else {
            completion(nil, "Invalid URL")
            return
        }
        
        // Make the network call
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for network errors
            if let error = error {
                completion(nil, "Network error: \(error.localizedDescription)")
                return
            }
            
            // Check if we got data
            guard let data = data else {
                completion(nil, "No data received")
                return
            }
            
            // Check response status
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 0
            
            if statusCode == 404 {
                completion(nil, "Sensor not found")
                return
            }
            
            // Parse the status
            if let status = try? JSONDecoder().decode(SensorStatus.self, from: data) {
                completion(status, nil)
            } else {
                completion(nil, "Failed to parse sensor status")
            }
        }
        
        task.resume()
    }
    
    // Turn on a sensor
    func activateSensor(sensorName: SensorName, completion: @escaping (SensorStatus?, String?) -> Void) {
        // Create the URL
        let urlString = "\(baseURL)/sensor-status/\(sensorName.rawValue)/activate"
        guard let url = URL(string: urlString) else {
            completion(nil, "Invalid URL")
            return
        }
        
        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Make the network call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for network errors
            if let error = error {
                completion(nil, "Network error: \(error.localizedDescription)")
                return
            }
            
            // Check if we got data
            guard let data = data else {
                completion(nil, "No data received")
                return
            }
            
            // Check response status
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 0
            
            if statusCode == 404 {
                completion(nil, "Sensor not found")
                return
            }
            
            // Parse the updated status
            if let status = try? JSONDecoder().decode(SensorStatus.self, from: data) {
                completion(status, nil)
            } else {
                completion(nil, "Failed to parse sensor status")
            }
        }
        
        task.resume()
    }
    
    // Turn off a sensor
    func deactivateSensor(sensorName: SensorName, completion: @escaping (SensorStatus?, String?) -> Void) {
        // Create the URL
        let urlString = "\(baseURL)/sensor-status/\(sensorName.rawValue)/deactivate"
        guard let url = URL(string: urlString) else {
            completion(nil, "Invalid URL")
            return
        }
        
        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Make the network call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for network errors
            if let error = error {
                completion(nil, "Network error: \(error.localizedDescription)")
                return
            }
            
            // Check if we got data
            guard let data = data else {
                completion(nil, "No data received")
                return
            }
            
            // Check response status
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 0
            
            if statusCode == 404 {
                completion(nil, "Sensor not found")
                return
            }
            
            // Parse the updated status
            if let status = try? JSONDecoder().decode(SensorStatus.self, from: data) {
                completion(status, nil)
            } else {
                completion(nil, "Failed to parse sensor status")
            }
        }
        
        task.resume()
    }
}
