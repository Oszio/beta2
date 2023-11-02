import SwiftUI
import Firebase
import Kingfisher

struct FeedView: View {
    @State private var friends: [Friend] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading Friends...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(friends) { friend in
                        NavigationLink(destination: FriendProfileView(friend: friend)) {
                            FriendProfileInfoRow(friend: friend)
                        }
                        FriendRow(friend: friend)
                        .listRowBackground(Color(UIColor.systemGroupedBackground))
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationBarTitleDisplayMode(.large)
                }
            }
            .onAppear(perform: loadFriends)
        }
    }

    func loadFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "Error: Unable to get current user ID"
            isLoading = false
            return
        }

        Task {
            do {
                let dbUsers = try await UserManager.shared.fetchFriends(for: currentUserID)
                // Convert DBUser objects to Friend objects
                friends = dbUsers.map {
                    Friend(from: $0, friendDocument: FriendDocument(friendID: $0.uid, timestamp: Timestamp(date: Date())))
                }
                isLoading = false
            } catch {
                errorMessage = "Error fetching friends: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}



struct FriendRow: View {
    var friend: Friend
    
    @State private var completedChallenges: [CompletedChallenge] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ForEach(completedChallenges) { challenge in
                    CompletedChallengeRow(challenge: challenge)
                }
            }
        }
        .padding(.horizontal, 16)
        .onAppear(perform: loadCompletedChallenges)
    }

    
    func loadCompletedChallenges() {
        Task {
            do {
                completedChallenges = try await FirebaseManager.shared.fetchCompletedChallenges(forUID: friend.id)
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = "Error fetching completed challenges: \(error.localizedDescription)"
            }
        }
    }
}

struct FriendProfileInfoRow: View {
    var friend: Friend

    var body: some View {
        HStack(spacing: 12) {
            FriendProfilePicture(url: friend.photoUrl)
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.email ?? "No Email")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct CompletedChallengeRow: View {
    var challenge: CompletedChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CompletedChallengeImage(url: challenge.imageUrl)
            Text(challenge.comment)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct FriendProfilePicture: View {
    var url: String?

    var body: some View {
        Group {
            if let urlString = url, let imageUrl = URL(string: urlString) {
                KFImage(imageUrl)
                    .resizable()
                    .placeholder {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .fade(duration: 0.25) // Fade-in effect with duration
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    }
}

struct CompletedChallengeImage: View {
    var url: String

    var body: some View {
        if let imageUrl = URL(string: url) {
            KFImage(imageUrl)
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .fade(duration: 0.25) // Fade-in effect with duration
                .cornerRadius(8)
                .frame(height: 200)
        }
    }
}
