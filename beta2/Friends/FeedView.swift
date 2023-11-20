import SwiftUI
import Firebase
import Kingfisher

struct FriendChallenge: Identifiable {
    var id: String { "\(friend.id)-\(challenge.id)" }
    var friend: Friend
    var challenge: CompletedChallenge
}

struct FeedView: View {
    let uid: String
    @State private var friends: [Friend] = []
    @State private var allChallenges: [FriendChallenge] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("UNPAUSE.")
                        .font(.custom("Avenir", size: 20))
                        .kerning(2)
                    Divider()
                    
                    if isLoading {
                        ProgressView()
                    } else {
                        let sortedChallenges = allChallenges.sorted(by: { $0.challenge.completionTime > $1.challenge.completionTime })
                        ForEach(sortedChallenges) { friendChallenge in
                            FriendChallengeRow(uid: uid, friend: friendChallenge.friend, challenge: friendChallenge.challenge, navigation: true)
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await loadFeedData()
                }
            }
        }
    }
    
    func loadFeedData() async {
        allChallenges = []
        isLoading = true
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "Error: Unable to get current user ID"
            isLoading = false
            return
        }
        
        do {
            let dbUsers = try await UserManager.shared.fetchFriends(for: currentUserID)
            self.friends = dbUsers.map {
                Friend(from: $0, friendDocument: FriendDocument(friendID: $0.uid, timestamp: Timestamp(date: Date())))
            }
            
            await withTaskGroup(of: [FriendChallenge].self) { group in
                for friend in self.friends {
                    group.addTask {
                        do {
                            let challenges = try await FirebaseManager.shared.fetchCompletedChallenges(forUID: friend.id)
                            return challenges.map { FriendChallenge(friend: friend, challenge: $0) }
                        } catch {
                            print("Error fetching challenges for friend \(friend.id): \(error)")
                            return []
                        }
                    }
                }
                
                for await friendChallenges in group {
                    self.allChallenges.append(contentsOf: friendChallenges)
                }
            }
            
            self.allChallenges.sort(by: { $0.challenge.completionTime > $1.challenge.completionTime })
            self.isLoading = false
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error fetching data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}
    
    struct FriendRow: View {
        let uid: String
        var friend: Friend
        var navigation: Bool
        
        let dimension = UIScreen.main.bounds.width
        
        @State private var recentChallenges: [CompletedChallenge] = []
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
                    ForEach(recentChallenges.reversed()) { challenge in
                        // Display each recent challenge
                        FriendChallengeRow(uid: uid, friend: friend, challenge: challenge, navigation: navigation)
                    }
                }
            }
            //.padding(.horizontal, 16)
            .onAppear(perform: loadRecentChallenges)
        }
        
        func loadRecentChallenges() {
            Task {
                do {
                    recentChallenges = try await FirebaseManager.shared.fetchCompletedChallenges(forUID: friend.id)
                    isLoading = false
                } catch {
                    isLoading = false
                    errorMessage = "Error fetching completed challenges: \(error.localizedDescription)"
                }
            }
        }
    }
    
    struct FriendChallengeRow: View {
        let uid: String
        var friend: Friend
        var challenge: CompletedChallenge
        var navigation: Bool
        
        @State private var isShowingComments = false
        @State private var isShowingCommentPostView = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                
                
                // Display a single challenge
                ZStack {
                    if navigation {
                        NavigationLink(destination: FriendProfileView(uid: uid, friend: friend)) {
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
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 70)
                    .padding(.trailing, 13)
                    .padding(.top, 35)
                }
                
                CompletedChallengeImage(url: challenge.imageUrl, challenge: challenge)
                
                Text(challenge.comment)
                    .font(.subheadline)
                   .foregroundColor(.secondary)
                   .padding(.leading, 13)
               Button("View all comments") {
                   isShowingCommentPostView = true
               }
               .sheet(isPresented: $isShowingCommentPostView) {
                   FriendCommentSectionView(completedChallengeID: challenge.id, userId: friend.id)
               }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 13)
               }
               .padding(.top, 8)
               //.padding(.leading, 13)

               Spacer()
               Divider()
           }
           

       private let dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateStyle = .short
           formatter.timeStyle = .short
           return formatter
       }()
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
                        //.frame(width: dimension)
                        //.scaledToFill() // Crop the image
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
    
    
    
