//
//  CategoryView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//

import SwiftUI



struct CategoryView: View {
    @ObservedObject var challengeData: ChallengeData
    @ObservedObject var achievementData: AchievementData
    @Binding var activeView: ActiveView
    @State private var selectedCategory: ChallengeCategory = .active
    @State private var showCategoryBoxes = false // Added state for showing/hiding boxes
    @Binding var showSignInView: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack{
                    Spacer()
                    Button(action: {
                        showCategoryBoxes.toggle()
                        
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.title)
                            .foregroundColor(Color.primary)
                            .padding()
                    }
                }
                    if showCategoryBoxes { // Conditionally show the boxes
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(ChallengeCategory.allCases, id: \.self) { category in
                                    CategoryBoxView(category: category)
                                        .onTapGesture {
                                            selectedCategory = category
                                            
                                        }
                                }
                            }
                            .padding()
                        }
                        
                    }
                    
                    TabView(selection: $selectedCategory) {
                        ForEach(ChallengeCategory.allCases, id: \.self) { category in
                            PathView(challengeData: challengeData, achievementData: achievementData, selectedCategory: category)
                                .tag(category)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    //.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
            .navigationBarTitle("", displayMode: .inline)
            VStack {
                Text("Category View")
                NavigationLink("Info View", destination: InfoView(activeView: $activeView, challengeData: challengeData, achievementData: achievementData))
                NavigationLink("User View", destination: UserView(achievementData: achievementData, challengeData: challengeData, activeView: $activeView))
            }
            .onAppear {
                activeView = .category
            }
        }
    }
}

struct CategoryBoxView: View {
    let category: ChallengeCategory
    
    // Define colors based on category
    var backgroundColor: Color {
        switch category {
        case .active:
            return Color(red: (100)/255, green: (100)/255, blue: (100)/255)
        case .nature:
            return Color(red: (28+95)/255, green: (77+110)/255, blue: (42+95)/255) // Change this to the desired color
        case .social:
            return Color(red: (100)/255, green: (110)/255, blue: (255)/255) // Change this to the desired color
        case .food:
            return Color(red: (240)/255, green: (185)/255, blue: (85)/255) // Change this to the desired color
        case .culture:
            return Color(red: (185)/255, green: (135)/255, blue: (240)/255) // Change this to the desired color
        case .kindness:
            return Color(red: (255)/255, green: (100)/255, blue: (100)/255) // Change this to the desired color
        case .mindfulness:
            return Color(red: (100)/255, green: (100)/255, blue: (145)/255) // Change this to the desired color
        case .daily:
            return Color(red: (240)/255, green: (145)/255, blue: (85)/255) // Change this to the desired color
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: (250)/255, green: (250)/255, blue: (250)/255))
                    .frame(width: 60, height: 60)
                
                Image(systemName: symbolName(for: category))
                    .font(.system(size: 20))
                    .foregroundColor(backgroundColor)
                    .padding()
            }
            Text(category.displayName)
                .font(.system(size: 12))
                .foregroundColor(Color.primary)
                .multilineTextAlignment(.center)
        }
       // .background(backgroundColor)
    }

    func symbolName(for category: ChallengeCategory) -> String {
        switch category {
        case .active:
            return "figure.walk"
        case .nature:
            return "leaf.fill"
        case .social:
            return "person.2.fill"
        case .food:
            return "fork.knife"
        case .culture:
            return "paintpalette.fill"
        case .kindness:
            return "heart.fill"
        case .mindfulness:
            return "face.smiling.fill"
        case .daily:
            return "flame.fill"
        }
    }
    
}

