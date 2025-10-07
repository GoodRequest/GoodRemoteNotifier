//
//  MessageFrequency.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 17/04/2025.
//

public enum MessageFrequency: String, Codable, Sendable {
    case once, daily, weekly, monthly, always
}
