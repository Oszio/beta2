//
//  GradientProgressBar.swift
//  beta2
//
//  Created by Oskar Almå on 2023-09-24.
//

import SwiftUI

struct GradientCircularProgressBar: View {
    @Binding var progress: Double

    var body: some View {
        GeometryReader { geometry in
            
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(Color.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topTrailing, endPoint: .bottomLeading), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
        }
        .onAppear()
        .animation(.easeIn, value: progress)
        
        .frame(width: 50, height: 50)  // Adjust these values to your preferred size
    }
}

