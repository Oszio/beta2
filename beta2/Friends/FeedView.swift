import SwiftUI
import Firebase
import Kingfisher

struct FeedView: View {
    @State private var friends: [Friend] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(friends, id: \.id) { friend in
                        VStack(spacing: 0) {
                            ZStack{
                                FriendRow(friend: friend)
                                    .background(Color(UIColor.systemGroupedBackground))
                                    .cornerRadius(16)
                                    .padding(.bottom, 8)
                                VStack{
                                    NavigationLink(destination: FriendProfileView(friend: friend)) {
                                        FriendProfileInfoRow(friend: friend)
                                            .padding(.top, 13)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(16)
            }
            .onAppear(perform: loadFriends)
            .background(Color(UIColor.systemGroupedBackground)) // Set background color for visibility
            //.ignoresSafeArea(.all)
        }
    }

    func loadFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        Task {
            do {
                let dbUsers = try await UserManager.shared.fetchFriends(for: currentUserID)
                // Convert DBUser objects to Friend objects
                self.friends = dbUsers.map { Friend(from: $0, friendDocument: FriendDocument(friendID: $0.uid, timestamp: Timestamp(date: Date()))) }
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
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ForEach(completedChallenges.prefix(5).reversed()) { challenge in
                    CompletedChallengeRow(challenge: challenge)
                        .padding(.horizontal, 0)
                }
            }
        }
        .onAppear(perform: loadCompletedChallenges)
        .listRowInsets(EdgeInsets())
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
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    }
}

struct CompletedChallengeImage: View {
    var url: String
    let dimention = UIScreen.main.bounds.width

    var body: some View {
        if let imageUrl = URL(string: url) {
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: UIScreen.main.bounds.width, height: dimention + 125)
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
}


