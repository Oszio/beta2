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
                            Text("SIDEQUEST")
                                .font(.custom("Avenir", size: 20))
                                //.bold()
                                .kerning(2)
                            Divider()
                            ForEach(friends, id: \.id) { friend in
                                FriendRow(friend: friend, navigation: true)
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
    var navigation: Bool
    
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
                ForEach(completedChallenges.reversed()) { challenge in
                    VStack(alignment: .leading){
                        // Other content related to friend, if needed
                        ZStack{
                            if navigation {
                                NavigationLink(destination: FriendProfileView(friend: friend)) {
                                    FriendProfileInfoRow(friend: friend)
                                }
                                .padding(.leading, 13)
                            } else {
                                FriendProfileInfoRow(friend: friend)
                                    .padding(.leading, 13)
                            }
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
                            .padding(.leading, 70)
                            .padding(.trailing, 13)
                            .padding(.top, 35)
                        }
                        CompletedChallengeImage(url: challenge.imageUrl, challenge: challenge)
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
                        Spacer()
                        Divider()
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
            CompletedChallengeImage(url: challenge.imageUrl, challenge: challenge)
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
            CompletedChallengeImage(url: challenge.imageUrl, challenge: challenge)
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
        .aspectRatio(contentMode: .fill)
        .frame(width: 48, height: 48)
        .clipShape(Circle())
        .background(
            Circle()
                .foregroundColor(.clear)
                .frame(width: 51, height: 51) // Adjust the size of the background circle
        )
    }
}

struct HeartMask: View {
    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
struct CircleMask: Shape {
    func path(in rect: CGRect) -> Path {
        return Path(ellipseIn: rect)
    }
}

struct CompletedChallengeImage: View {
    var url: String
    var challenge: CompletedChallenge
    @State private var isLoading: Bool = false
    @State private var isChallengeInfoLoaded: Bool = false
    @State private var challengeInfo: Challenge? // Declare challengeInfo as a property
    
    let dimension = UIScreen.main.bounds.width
    @State private var isTapped: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if let imageUrl = URL(string: url) {
                KFImage(imageUrl)
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .fade(duration: 0.25)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: dimension, height: dimension)
                    .clipped()
            }

            if isTapped {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text(challenge.categoryID.uppercased() + " CHALLENGE:")
                        .font(.custom("Avenir", size: 30))
                        .foregroundColor(.white)
                        .italic()
                        .padding(.top, 10)
                    if isChallengeInfoLoaded, let challengeInfo = challengeInfo {
                        Text(challengeInfo.description)
                            .font(.custom("Avenir", size: 20))
                            .foregroundColor(.white)
                            .italic()
                    } else if isChallengeInfoLoaded {
                        Text("Challenge info not found")
                            .font(.custom("Avenir", size: 20))
                            .foregroundColor(.white)
                            .italic()
                    }
                    Spacer()
                }
            }
        }
        .onTapGesture {
            withAnimation {
                isTapped.toggle()
            }
        }
        .onAppear(perform: fetchChallengeInfo)
    }

    func fetchChallengeInfo() {
        isLoading = true
        Task {
            do {
                // Fetch a single challenge based on challengeID
                challengeInfo = try await ChallengeManager.shared.fetchChallenge(byID: challenge.challengeID, inCategory: challenge.categoryID)
                if challengeInfo == nil {
                    print("Challenge not found for ID: \(challenge.challengeID)")
                }
                isChallengeInfoLoaded = true
            } catch {
                print("Failed to fetch challenge: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
}


