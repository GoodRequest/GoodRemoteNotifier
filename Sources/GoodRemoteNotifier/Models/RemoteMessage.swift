//
//  RemoteMessage.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 17/04/2025.
//

internal struct RemoteMessage: Decodable {

    let title, message: [String: String]
    let updateButton, closeButton: [String: String]?
    let frequency: MessageFrequency?

    func localizedString(of keyPath: KeyPath<RemoteMessage, [String: String]>, for languageCode: String) -> String? {
        self[keyPath: keyPath][languageCode]
    }

    func localizedOptionalString(of keyPath: KeyPath<RemoteMessage, [String: String]?>, for languageCode: String) -> String? {
        self[keyPath: keyPath]?[languageCode]
    }

    public func localizedMessage(languageCode: String) -> LocalizedRemoteMessage? {
        LocalizedRemoteMessage(
            title: localizedString(of: \.title, for: languageCode),
            message: localizedString(of: \.message, for: languageCode),
            updateButton: localizedOptionalString(of: \.updateButton, for: languageCode),
            closeButton: localizedOptionalString(of: \.closeButton, for: languageCode),
            frequency: frequency ?? .once
        )
    }

}
