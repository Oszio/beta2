//
//  FriendRequestView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-11-03.
//
import SwiftUI
import FirebaseFirestore

struct PendingFriendRequestsView: View {
 @ObservedObject var viewModel: PendingFriendRequestsViewModel

    var body: some View {
        NavigationView {
            List(viewModel.friendRequests) { request in
                // Assuming 'fromUsername' is a property you have added
                HStack {
                    Text(request.fromUserId)
                    Spacer()
                    Button("Accept") {
                        viewModel.acceptFriendRequest(request)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Reject") {
                        viewModel.rejectFriendRequest(request)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("Friend Requests")
            .onAppear {
                viewModel.fetchFriendRequests()
            }
            .alert("Error", isPresented: $viewModel.showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                }
            }
        }
    }
}

@MainActor
class PendingFriendRequestsViewModel: ObservableObject {
    @Published var friendRequests: [FriendRequest] = []
    @Published var isLoading = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    
    let userManager = UserManager.shared
    let authManager = AuthenticationManager.shared
    
    func fetchFriendRequests() {
        isLoading = true
        Task {
            do {
                // Attempt to retrieve the current authenticated user
                let authDataResult = try authManager.getAuthenticatedUser()
                // Use the UID from the authenticated user
                friendRequests = try await userManager.fetchFriendRequests(for: authDataResult.uid)
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isLoading = false
        }
    }
    
    func acceptFriendRequest(_ request: FriendRequest) {
        Task {
            do {
                try await userManager.acceptFriendRequest(request)
                // Refresh the list after accepting
                fetchFriendRequests()
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
    
    func rejectFriendRequest(_ request: FriendRequest) {
        Task {
            do {
                try await userManager.rejectFriendRequest(request)
                // Refresh the list after rejecting
                fetchFriendRequests()
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
}