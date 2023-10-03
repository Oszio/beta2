//
//  ChallengeDetailView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-03.
//

import SwiftUI

struct ChallengeDetailView: View {
    var challenge: Challenge
    @State private var showUploadEvidenceView: Bool = false
    @State private var evidenceImage: UIImage? = nil // This will hold the uploaded evidence
    
    var body: some View {
        VStack(spacing: 20) {
            Text(challenge.title)
                .font(.largeTitle)
                .padding()
            
            Text(challenge.description)
                .font(.body)
                .padding()
            
            // Display the evidence image if available
            if let image = evidenceImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            Button("Upload Evidence") {
                showUploadEvidenceView = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Spacer()
        }
        .sheet(isPresented: $showUploadEvidenceView) {
            UploadEvidenceView(uploadedImage: $evidenceImage, challenge: challenge) // Pass the binding to the evidenceImage
        }
    }
}

