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
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(friends, id: \.id) { friend in
                                FriendRow(friend: friend)
                            }
                        }
                    }
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
    let dimention = UIScreen.main.bounds.width
    
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
                // Last 3 challenges per person in newest order
                ForEach(completedChallenges.prefix(3).reversed()) { challenge in
                    VStack(alignment: .leading){
                        // Other content related to friend, if needed
                        NavigationLink(destination: FriendProfileView(friend: friend)) {
                            FriendProfileInfoRow(friend: friend)
                        }
                            .padding(.leading, 13)
                        HStack {
                            Text("\(challenge.completionTime, formatter: dateFormatter)") // Display timestamp
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Points: 10")
                            //Text("Points: \(challenge.points)") // Display points
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                            .padding(.leading, 13)
                            .padding(.trailing, 13)
                        CompletedChallengeImage(url: challenge.imageUrl)
                        HStack {
                            Text(challenge.comment)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "message") // Assuming "message" is the name of the comment icon
                                .foregroundColor(.secondary)
                        }
                            .padding(.top, 8) // Add padding between image and caption
                            .padding(.leading, 13)
                            .padding(.trailing, 13)
                    }
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
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}


struct FriendChallengeRow: View {
    var friend: Friend
    var challenge: CompletedChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CompletedChallengeImage(url: challenge.imageUrl)
            Text(challenge.comment)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8) // Add padding between image and caption
                .padding(.leading, 13)
        }
    }
}

struct FriendProfileInfoRow: View {
    var friend: Friend

    var body: some View {
        HStack(spacing: 12) {
        FriendProfilePicture(url: friend.photoUrl)
            Text(friend.username ?? "No Username")
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

struct CompletedChallengeRow: View {
    var challenge: CompletedChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
        .frame(width: 45, height: 45)
        .clipShape(Circle())
        .background(
            Circle()
                .foregroundColor(.green)
                .frame(width: 48, height: 48) // Adjust the size of the background circle
        )
    }
}

struct CompletedChallengeImage: View {
    var url: String
    let dimention = UIScreen.main.bounds.width

    var body: some View {
        if let imageUrl = URL(string: url) {
            KFImage(imageUrl)
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .fade(duration: 0.25)
                .frame(width: dimention, height: dimention - 20) // Adjust the size as needed
        }
    }
}
