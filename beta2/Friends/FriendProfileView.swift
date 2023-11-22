//
//  FriendProfileView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-19.
//

import SwiftUI
import Kingfisher

struct FriendProfileView: View {
    let uid: String
    var friend: Friend
    
    @State private var completedChallenges: [CompletedChallenge] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var isShowingRemoveConfirmation = false
    
    @State private var userInfo: UserInfo?
    @State private var usernameFromInfo: String = ""

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if let url = userInfo?.photoUrl, let imageUrl = URL(string: url) {
                    KFImage(imageUrl)
                        .resizable()
                        .loadDiskFileSynchronously() // Loads the image from the disk cache synchronously
                        .cacheMemoryOnly() // Stores the image in memory cache only
                        .fade(duration: 0.25) // Adds a fade animation when the image gets loaded
                        .onProgress { receivedSize, totalSize in  // Handle progress
                            // Optionally handle progress here
                        }
                        .onSuccess { result in  // Handle success
                            // Optionally handle success here
                        }
                        .onFailure { error in  // Handle failure
                            // Optionally handle failure here
                        }
                        .placeholder {
                            ProgressView() // Placeholder while loading or if there's an error
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.gray)
                }
                Text(userInfo?.username ?? "no username")
                    .font(.headline)
                    .foregroundColor(.primary)
                

                Button("Remove Friend") {
                    isShowingRemoveConfirmation.toggle()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                .alert(isPresented: $isShowingRemoveConfirmation) {
                    Alert(
                        title: Text("Remove Friend"),
                        message: Text("Are you sure you want to remove \(friend.username ?? "this friend")?"),
                        primaryButton: .destructive(Text("Remove")) {
                            // Call the removeFriend function when confirmed
                            removeFriend()
                        },
                        secondaryButton: .cancel()
                    )
                }

                Divider()

                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    FriendRow(uid: uid, friend: friend, navigation: false)
                }
            }
            //.padding()
            .onAppear(perform: loadCompletedChallenges)
            .task {
                do {
                    userInfo = try await UserManager.shared.fetchUserInfo(byUID: friend.friendID)
                    usernameFromInfo = userInfo?.username ?? ""
                    print(userInfo?.username ?? "No username found")
                } catch {
                    print("Error fetching user info: \(error.localizedDescription)")
                }
            }
        }
        .navigationBarTitle(userInfo?.username ?? "no username", displayMode: .inline)
    }
    
    func fetchUserInfo() async {
        do {
            userInfo = try await UserManager.shared.fetchUserInfo(byUID: uid)
            print(userInfo?.username ?? "No username found")
        } catch {
            print("Error fetching user info: \(error.localizedDescription)")
        }
    }
    
    func loadCompletedChallenges() {
        Task {
            do {
                self.completedChallenges = try await FirebaseManager.shared.fetchCompletedChallenges(forUID: friend.id)
                self.isLoading = false
            } catch {
                self.isLoading = false
                errorMessage = "Error fetching completed challenges: \(error.localizedDescription)"
            }
        }
    }

    func removeFriend() {
        Task {
            do {
                try await UserManager.shared.removeFriend(currentUserID: uid, friendID: friend.id)
                // Optionally, you can navigate back after removing the friend
                // For example, using presentationMode or NavigationLink
            } catch {
                // Handle the error if removal fails
                print("Error removing friend: \(error.localizedDescription)")
            }
        }
    }
}
