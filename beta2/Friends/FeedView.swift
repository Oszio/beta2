import SwiftUI
import Firebase

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
                            FriendRow(friend: friend)
                        }
                        .listRowBackground(Color(UIColor.systemGroupedBackground))
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("Friends")
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
                    FriendChallengeRow(friend: friend, challenge: challenge)
                        .padding(.vertical, 8)
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



struct FriendChallengeRow: View {
    var friend: Friend
    var challenge: CompletedChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                FriendProfilePicture(url: friend.photoUrl)
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.email ?? "No Email")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(challenge.comment)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            CompletedChallengeImage(url: challenge.imageUrl)
        }
    }
}

struct FriendProfilePicture: View {
    var url: String?

    var body: some View {
        Group {
            if let urlString = url, let imageUrl = URL(string: urlString) {
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 40, height: 40)
    }
}

struct CompletedChallengeImage: View {
    var url: String

    var body: some View {
        if let imageUrl = URL(string: url) {
            AsyncImage(url: imageUrl) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .cornerRadius(8)
            .frame(height: 200)
        }
    }
}
