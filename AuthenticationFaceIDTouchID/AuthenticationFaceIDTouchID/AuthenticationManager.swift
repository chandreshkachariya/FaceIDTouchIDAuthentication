//
//  AuthenticationManager.swift
//  AuthenticationFaceIDTouchID
//
//  Created by Chandresh Kachariya on 11/11/22.
//

import Foundation
import LocalAuthentication

class AuthenticationManager: ObservableObject {
    private(set) var context = LAContext()
    @Published private(set) var biometryType: LABiometryType = .none
    private(set) var canEvaluatePolicy = false
    @Published private(set) var isAuthenticated = false
    @Published private(set) var errorDescription: String?
    @Published var showAlert = false
    
    init() {
        getBiometryType()
    }
    
    func getBiometryType() {
        canEvaluatePolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        biometryType = context.biometryType
    }
    

    func authenticateWithBiometrics() async {
        context = LAContext()
        
        if canEvaluatePolicy {
            let reason = "Log into your account"
            
            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
                if success {
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                        UserDefaults.standard.set(true, forKey: "isFaceIDSetup")
                        print("isAuthenticated", self.isAuthenticated)
                    }
                }
            } catch {
                print(error.localizedDescription )
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    self.errorDescription = error.localizedDescription
                    self.showAlert = true
                    self.biometryType = .none
                }
            }
        }
    }
    
    func authenticateWithCredentials(username: String, password: String) {
        if username.lowercased() == "chandresh" && password == "123456" {
            UserDefaults.standard.set(username, forKey: "username")
            UserDefaults.standard.set(password, forKey: "password")

            isAuthenticated = true
        }
        else {
            errorDescription = "Wrong Credentials."
            showAlert = true
        }
    }
    
    func logout() {
        isAuthenticated = false
        UserDefaults.standard.set(false, forKey: "isFaceIDSetup")
    }
}
