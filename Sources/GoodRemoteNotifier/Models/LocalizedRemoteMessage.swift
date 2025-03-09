//
//  LocalizedRemoteMessage.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 17/04/2025.
//

struct LocalizedRemoteMessage: Codable {

    let id, title, message: String
    let updateButton, closeButton: String?
    let frequency: MessageFrequency

    init?(title: String?, message: String?, updateButton: String?, closeButton: String?, frequency: MessageFrequency) {
        guard let title, let message else { return nil }

        self.id = title+message+frequency.rawValue
        self.title = title
        self.message = message
        self.updateButton = updateButton
        self.closeButton = closeButton
        self.frequency = frequency
    }

}
