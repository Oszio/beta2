//
//  ChallengeModel.swift
//  beta2
//
//  Created by Oskar Almå on 2023-10-12.
//

import Foundation

struct ChallengeCategory: Identifiable, Codable, Hashable {
    var id: String  // categoryID
    var name: String
    var description: String
}

struct Challenge: Identifiable, Codable, Hashable {
    var id: String  // challengeID
    var name: String
    var description: String
    var points: Int
    var evidenceRequired: Bool
    var sequence: Int
}
