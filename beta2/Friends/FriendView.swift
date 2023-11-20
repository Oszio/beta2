//
//  FriendView.swift
//  beta2
//
//  Created by Petter Uvdal on 2023-11-01.
//

import SwiftUI

struct FriendView: View {
    let uid: String
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                FriendSearchView()
                    .frame(height: UIScreen.main.bounds.height * 0.5) // Adjust the percentage as needed
                    .padding()

                FriendListView(uid: uid)
                    .background(Color(.systemGray6))
            }
        }
    }
}
