//
//  AnimatedBackground.swift
//  beta2
//
//  Created by Oskar Almå on 2023-11-15.
//
import SwiftUI

struct AnimatedBackgroundView: View {
    let snowflakeCount = 100

    var body: some View {
        ZStack {
            Color.blue.opacity(0.3) // Plain background for visibility

            ForEach(0..<snowflakeCount, id: \.self) { _ in
                SnowflakeView()
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: 0) // Start from the top
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SnowflakeView: View {
    private let size: CGFloat = CGFloat.random(in: 10...30)
    private let opacity: Double = Double.random(in: 0.3...0.8)
    private let startDelay: Double = Double.random(in: 0...5)
    private let animationDuration: Double = Double.random(in: 7...12)
    private let xOffset: CGFloat = CGFloat.random(in: -30...30) // For subtle horizontal drift
    private let rotation: Double = Double.random(in: 0...360) // Random initial rotation

    @State private var isFalling = false

    var body: some View {
        Image(systemName: "snowflake")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .offset(x: isFalling ? xOffset : 0, y: isFalling ? UIScreen.main.bounds.height + 100 : 0)
            .onAppear {
                withAnimation(Animation.linear(duration: animationDuration).delay(startDelay).repeatForever(autoreverses: false)) {
                    isFalling = true
                }
            }
    }
}

// another way to show snowflakes

/*  import SwiftUI

struct AnimatedBackgroundView: View {
    let snowflakeCount = 100

    var body: some View {
        ZStack {
            Color.blue.opacity(0.3)

            ForEach(0..<snowflakeCount, id: \.self) { _ in
                SnowflakeView()
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: 0)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SnowflakeView: View {
    private let size: CGFloat = CGFloat.random(in: 10...30)
    private let opacity: Double = Double.random(in: 0.3...0.8)
    private let startDelay: Double = Double.random(in: 0...5)
    private let animationDuration: Double = Double.random(in: 7...12)
    private let xOffset: CGFloat = CGFloat.random(in: -30...30)
    private let rotation: Double = Double.random(in: 0...360)

    @State private var isFalling = false

    var body: some View {
        Image(systemName: "snowflake")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .opacity(isFalling ? opacity : 0) // Fade out effect
            .rotationEffect(.degrees(isFalling ? rotation : 0))
            .offset(x: isFalling ? xOffset : 0, y: isFalling ? UIScreen.main.bounds.height + 100 : 0)
            .onAppear {
                withAnimation(Animation.linear(duration: animationDuration).delay(startDelay).repeatForever(autoreverses: false)) {
                    isFalling = true
                }
            }
    }
}

*/
