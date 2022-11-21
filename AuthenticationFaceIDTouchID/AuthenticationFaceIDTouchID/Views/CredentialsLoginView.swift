//
//  CredentialsLoginView.swift
//  AuthenticationFaceIDTouchID
//
//  Created by Chandresh Kachariya on 11/11/22.
//

import SwiftUI

struct CredentialsLoginView: View {
//    @EnvironmentObject var authenticationManager: AuthenticationManager
    @StateObject var authenticationManager = AuthenticationManager()

    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                if authenticationManager.isAuthenticated {
                    VStack(spacing: 40) {
                        
                        Title()
                        
                        Text("Welcome, you aree authenticated.")
                            .foregroundColor(.white)
                        
                        if !UserDefaults.standard.bool(forKey: "isFaceIDSetup") {
                            
                            VStack(spacing: 40) {
                                
                                switch authenticationManager.biometryType {
                                case .faceID:
                                    PrimaryButton(image: "faceid", text: "Setup Login with FaceID")
                                        .onTapGesture {
                                            Task.init {
                                                await authenticationManager.authenticateWithBiometrics()
                                            }
                                        }
                                case .touchID:
                                    PrimaryButton(image: "touchid", text: "Setup Login with TouchId")
                                        .onTapGesture {
                                            Task.init {
                                                await authenticationManager.authenticateWithBiometrics()
                                            }
                                        }
                                default:
                                    PrimaryButton(showImage: false, text: "FaceID or TouchId is not supported")
                                }
                            }
                        }
                        
                        PrimaryButton(showImage: false, text: "Logout")
                            .onTapGesture {
                                authenticationManager.logout()
                            }
                    }
                } else {
                    Title()
                    
                    TextField("username", text: $username)
                    
                    SecureField("Password", text: $password)
                    
                    PrimaryButton(showImage: false, text: "Login")
                        .onTapGesture {
                            authenticationManager.authenticateWithCredentials(username: username, password: password)
                        }
                }
                
            }
            .textFieldStyle(.roundedBorder)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
            .alert(isPresented: $authenticationManager.showAlert) {
                Alert(title: Text("Error"), message: Text(authenticationManager.errorDescription ?? "Error to try login with credentials"), dismissButton: .default(Text("Okay")))
            }
            
        }.onAppear() {
            if UserDefaults.standard.bool(forKey: "isFaceIDSetup") {
                
                Task.init {
                    await authenticationManager.authenticateWithBiometrics()
                }
            }
        }
        
    }
}

struct CredentialsLoginView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsLoginView()
    }
}
