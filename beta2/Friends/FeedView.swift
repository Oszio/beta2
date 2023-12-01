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
                LazyVStack(spacing: 16) {
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
            LazyVStack(alignment: .leading, spacing: 16) {
                if isLoading {
                    ProgressView()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    ForEach(recentChallenges) { challenge in
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
            LazyVStack(alignment: .leading, spacing: 8) {
                
                
                // Display a single challenge
                
                CompletedChallengeImage(uid: uid, friend: friend, url: challenge.imageUrl, challenge: challenge, navigation: navigation)
                
                    .padding(.top, 8)
                //.padding(.leading, 13)
                
                Spacer()
                
            }
        }
    }
    
    
    struct FriendProfileInfoRow: View {
        var friend: Friend
        var color: Color
        @State private var userInfo: UserInfo?

        var body: some View {
            HStack(spacing: 12) {
                FriendProfilePicture(url: userInfo?.photoUrl)
                Text(userInfo?.username ?? "No Username")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(color)
                Spacer()
            }
            .task {
                await fetchUserInfo()
            }
        }

        func fetchUserInfo() async {
            do {
                userInfo = try await UserManager.shared.fetchUserInfo(byUID: friend.friendID)
                print(userInfo?.username ?? "No username found")
            } catch {
                print("Error fetching user info: \(error.localizedDescription)")
            }
        }
    }


    
    struct CompletedChallengeRow: View {
        let uid: String
        var friend: Friend

        var challenge: CompletedChallenge
        var navigation: Bool
        
        var body: some View {
            LazyVStack(alignment: .leading, spacing: 0) {
                CompletedChallengeImage(uid: uid, friend: friend, url: challenge.imageUrl, challenge: challenge, navigation: navigation)
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
    
struct CompletedChallengeImage: View {
    let uid: String
    var friend: Friend
    var url: String
    var challenge: CompletedChallenge
    @State private var isLoading: Bool = false
    @State private var isChallengeInfoLoaded: Bool = false
    @State private var challengeInfo: Challenge? // Declare challengeInfo as a property
    @State private var isShowingComments = false
    @State private var isShowingCommentPostView = false
    var navigation: Bool
    
    let dimension = UIScreen.main.bounds.width
    @State private var isTapped: Bool = false
    @State private var isTappedSecond: Bool = false
    @State private var isTappedThird: Bool = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let imageUrl = URL(string: url) {
                KFImage(imageUrl)
                    .placeholder {
                        ProgressView()
                            .frame(width: dimension, height: dimension)
                    }
                    .fade(duration: 0.25)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: dimension)
                    .clipShape(Rectangle()) // Crop the image
                    .onTapGesture {
                        withAnimation {
                            isTappedSecond.toggle()
                        }
                    }
                    /*
                    .onLongPressGesture {
                        withAnimation {
                            isTappedThird.toggle()
                        }
                    }
                     */
            }
            ZStack{
                if isTapped {
                    VStack{
                        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0.7)]), startPoint: .top, endPoint: .center)
                            .frame(height: 150)
                            .opacity(0.8)
                        Spacer()
                        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.7)]), startPoint: .center, endPoint: .bottom)
                            .frame(height: 150)
                            .opacity(0.8)
                    }
                }
            }
            if isTappedThird{
                    VStack {
                        if navigation {
                            NavigationLink(destination: FriendProfileView(uid: uid, friend: friend)) {
                                FriendProfileInfoRow(friend: friend, color: .white)
                            }
                            .padding(.leading, 13)
                            .padding(.top, 13)
                        } else {
                            FriendProfileInfoRow(friend: friend, color: .white)
                                .padding(.leading, 13)
                                .padding(.top, 13)
                        }
                        if isTapped {
                            HStack{
                                Spacer()
                                Text("\(challenge.completionTime, formatter: dateFormatter)") // Display timestamp
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 40)
                            HStack{
                                Spacer()
                                Text("Points: 10")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 40)
                            HStack{
                                Spacer()
                                if isChallengeInfoLoaded, let challengeInfo = challengeInfo {
                                    Text(challengeInfo.description)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .italic()
                                } else {
                                    Text("")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.trailing, 40)
                        }
                        Spacer()
                        
                        HStack{
                            Text("Caption: \(challenge.comment)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Spacer()
                            Button {
                                isShowingCommentPostView.toggle()
                            } label: {
                                Image(systemName: "message")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.leading, 13)
                        }
                        .padding(.leading, 13)
                        .padding(.trailing, 13)
                        .sheet(isPresented: $isShowingCommentPostView) {
                            FriendCommentSectionView(completedChallengeID: challenge.id, userId: friend.id, uid: uid)
                        }
                        .padding(.bottom, 20)
                    }
                .onAppear(perform: fetchChallengeInfo)
                .overlay(
                    Button(action: {
                        withAnimation {
                            isTapped.toggle()
                        }
                    }, label: {
                        Image(systemName: "checkmark.square")
                            .foregroundColor(.white)
                        Text("\(challenge.categoryID)")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        Image(systemName: "chevron.down")
                            .frame(width: 10)
                            .foregroundColor(.white)
                            .padding()
                    })
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                    .onTapGesture {
                        withAnimation {
                            isTapped.toggle()
                        }
                    }
                    , alignment: .topTrailing
                )
            }
        }
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
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter
    }()
}


    
    
    
