//
//  AuthService.swift
//  ceport
//
//  Created on 11/26/2025.
//

import Foundation

// User data structure
struct User: Codable {
    let id: String
    let email: String
    let name: String?
    let createdAt: String?
}

// Class to handle login and registration
class AuthService: NSObject {
    // Shared instance to use throughout the app
    static let shared = AuthService()
    
    // API base URL
    private let baseURL = "https://ios-spot-nestjs-v1.vercel.app"
    
    private override init() {
        super.init()
    }
    
    // Login user with email and password
    func login(email: String, password: String, completion: @escaping (User?, String?) -> Void) {
        // Create the URL
        let urlString = "\(baseURL)/auth/login"
        guard let url = URL(string: urlString) else {
            completion(nil, "Invalid URL")
            return
        }
        
        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create JSON body
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
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
            
            if statusCode == 201 {
                // Success - parse the user
                if let user = try? JSONDecoder().decode(User.self, from: data) {
                    completion(user, nil)
                } else {
                    completion(nil, "Failed to parse user data")
                }
            } else if statusCode == 401 {
                completion(nil, "Invalid email or password")
            } else {
                completion(nil, "Login failed with status \(statusCode)")
            }
        }
        
        task.resume()
    }
    
    // Register new user account
    func register(email: String, password: String, name: String?, completion: @escaping (User?, String?) -> Void) {
        // Create the URL
        let urlString = "\(baseURL)/auth/register"
        guard let url = URL(string: urlString) else {
            completion(nil, "Invalid URL")
            return
        }
        
        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create JSON body
        var body: [String: Any] = ["email": email, "password": password]
        if let name = name {
            body["name"] = name
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
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
            
            if statusCode == 201 {
                // Success - parse the user
                if let user = try? JSONDecoder().decode(User.self, from: data) {
                    completion(user, nil)
                } else {
                    completion(nil, "Failed to parse user data")
                }
            } else if statusCode == 409 {
                completion(nil, "Email already registered")
            } else {
                completion(nil, "Registration failed with status \(statusCode)")
            }
        }
        
        task.resume()
    }
    
    // Get all users (for testing)
    func getAllUsers(completion: @escaping ([User]?, String?) -> Void) {
        // Create the URL
        let urlString = "\(baseURL)/auth/users"
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
            
            // Parse the users
            if let users = try? JSONDecoder().decode([User].self, from: data) {
                completion(users, nil)
            } else {
                completion(nil, "Failed to parse users")
            }
        }
        
        task.resume()
    }
}
