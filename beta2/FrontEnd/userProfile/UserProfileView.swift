//
//  UserProfileView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-03.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserProfileView: View {
    @State private var evidenceURLs: [URL] = []
    let userId: String // Assuming you have the user's ID

    var body: some View {
        VStack {
            List(evidenceURLs, id: \.self) { url in
                AsyncImage(url: url) { image in
                    image.resizable()
                         .scaledToFit()
                } placeholder: {
                    ProgressView() // This will show while the image is loading
                }
                .frame(width: 100, height: 100)
            }
        }
        .onAppear(perform: fetchEvidence)
    }

    func fetchEvidence() {
        Task {
            do {
                if let user = try await UserManager.shared.fetchUser(byUID: userId) {
                    self.evidenceURLs = user.evidence?.compactMap({ URL(string: $0) }) ?? []
                }
            } catch {
                print("Error fetching user evidence: \(error.localizedDescription)")
            }
        }
    }
}
