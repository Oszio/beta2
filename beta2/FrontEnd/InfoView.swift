//
//  InfoView.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//

import SwiftUI

struct InfoView: View {
    @Binding var activeView: ActiveView
    @ObservedObject var challengeData: ChallengeData
    @ObservedObject var achievementData: AchievementData
    @State private var showPopup = false
    @State private var showFirstPopup = false
    @State private var showSecondPopup = false
    @State private var showThirdPopup = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Welcome to SIDEQUEST")
                        .font(.custom("Avenir", size: 44))
                        .bold()
                        .italic()
                        .foregroundColor(Color.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.top, 50)
                    Spacer().frame(height: 30)
                }
                VStack {
                    Text("Thank you for participating in our Beta 1.0 test!")
                        .font(.custom("Avenir", size: 18))
                        .italic()
                        .foregroundColor(Color.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                    QuestionButton(question: "What does the app aim to achieve?", isExpanded: $showPopup)
                    if showPopup {
                        RoundedBoxView(content: "We are attempting to build a healthy social media app. This means that you won't get lost in an endless feed of content.")
                            .onTapGesture {
                                
                            }
                    }
                    QuestionButton(question: "What sets it apart from others?", isExpanded: $showSecondPopup)
                    if showSecondPopup {
                        RoundedBoxView(content: "We focus on providing meaningful interactions and experiences. This Beta-version serves as a testing ground for the key feature of challenges for well-being.")
                            .onTapGesture {
                               
                            }
                    }
                    
                    
                    QuestionButton(question: "How does the app handle my data?", isExpanded: $showFirstPopup)
                    if showFirstPopup {
                        RoundedBoxView(content: "Our approach is rooted in transparency: there won't be any tailored algorithms for ads or content.")
                            .onTapGesture {
                                
                            }
                    }
                    QuestionButton(question: "What do I need to do?", isExpanded: $showThirdPopup)
                    if showThirdPopup {
                        RoundedBoxView(content: "Enjoy the app, and kindly participate in the survey at ... \n\nWith regards,\nThe SideQuest Team.")
                            .onTapGesture {
                                
                            }
                    }
                    
                    
                    
                    
                }
            }
           
            }
            .onAppear {
                activeView = .info
            }
        }
    }

    struct RoundedBoxView: View {
        var content: String

        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(width: UIScreen.main.bounds.width - 20, height: 175)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 2) // Add a gray outline
                    )
                Text(content)
                    .font(.custom("Avenir", size: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    struct QuestionButton: View {
        var question: String
        @Binding var isExpanded: Bool

        var body: some View {
            Button(action: {
                isExpanded.toggle()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: (28+95)/255, green: (77+95)/255, blue: (42+95)/255))
                        .frame(width: UIScreen.main.bounds.width - 20, height: 80)
                    HStack {
                        Text(question)
                            .font(.custom("Avenir", size: 18))
                            .foregroundColor(Color.primary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 20))
                            .foregroundColor(Color.primary)
                            .padding()
                    }
                }
            }
        }
    }




