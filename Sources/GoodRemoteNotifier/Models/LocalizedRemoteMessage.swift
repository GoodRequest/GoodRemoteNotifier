//
//  LocalizedRemoteMessage.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 17/04/2025.
//

public struct LocalizedRemoteMessage: Codable & Sendable {

    public let id, title, message: String
    public let updateButton, closeButton: String?
    public let frequency: MessageFrequency

    public init?(
        title: String?,
        message: String?,
        updateButton: String?,
        closeButton: String?,
        frequency: MessageFrequency
    ) {
        guard let title, let message else { return nil }

        self.id = title+message+frequency.rawValue
        self.title = title
        self.message = message
        self.updateButton = updateButton
        self.closeButton = closeButton
        self.frequency = frequency
    }

}
