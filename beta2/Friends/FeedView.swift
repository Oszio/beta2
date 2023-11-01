import SwiftUI
import Firebase

struct FeedView: View {
    @State private var friends: [Friend] = []
    @State private var isLoadingFriends: Bool = true
    
    var body: some View {
        NavigationView {
            List {
                ForEach(friends) { friend in
                    NavigationLink(destination: FriendProfileView(friend: friend)) {
                        FriendRow(friend: friend)
                    }
                }
            }
            .onAppear(perform: loadFriends)
        }
    }

    func loadFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        Task {
            do {
                let dbUsers = try await UserManager.shared.fetchFriends(for: currentUserID)
                // Convert DBUser objects to Friend objects
                self.friends = dbUsers.map { Friend(from: $0, friendDocument: FriendDocument(friendID: $0.uid, timestamp: Timestamp(date: Date()))) }
                isLoadingFriends = false
            } catch {
                print("Error fetching friends: \(error.localizedDescription)")
            }
        }
    }
}

struct FriendRow: View {
    var friend: Friend
    
    @State private var completedChallenges: [CompletedChallenge] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                ForEach(completedChallenges) { challenge in
                    VStack(alignment: .leading) {
                        if let url = friend.photoUrl, let imageUrl = URL(string: url) {
                            AsyncImage(url: imageUrl) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        
                        Text(friend.email ?? "No Email")
                            .font(.title)
                        Text(challenge.comment)
                        if let url = URL(string: challenge.imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear(perform: loadCompletedChallenges)
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
}
