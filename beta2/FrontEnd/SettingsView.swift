//
//  SettingsView.swift
//  beta2
//
//  Created by Petter Uvdal on 2023-11-13.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showSignInView: Bool
    @State private var username: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showImagePicker: Bool = false
    @State private var showImageSourceSelectionActionSheet: Bool = false
    @State private var showImageSourceSelection: Bool = true

    var body: some View {
        Form {
            Section(header: Text("Profile Settings")) {
                TextField("Update Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Select Profile Picture") {
                    showingImagePicker = true
                }
                .actionSheet(isPresented: $showImageSourceSelectionActionSheet) {
                    ActionSheet(
                        title: Text("Select Image Source"),
                        buttons: [
                            .default(Text("Camera")) {
                                showImagePicker = true
                                showImageSourceSelection = false
                            },
                            .default(Text("Photo Album")) {
                                showImagePicker = true
                                showImageSourceSelection = true
                            },
                            .cancel()
                        ]
                    )
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $selectedImage, showImageSourceSelection: $showImageSourceSelection)
                }
                
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(50)
                }
                
                Button("Update Profile") {
                    // Call your updateProfile function here
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }

            Section {
                Button("Sign Out") {
                    signOut()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(8)
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
    }

    func updateProfile() {
        // Implement your updateProfile function here
    }

    func signOut() {
        do {
            try AuthenticationManager.shared.signOut()
            showSignInView = true
        } catch {
            print("Error signing out: \(error)")
        }
    }
}

