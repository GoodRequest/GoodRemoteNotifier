//
//  MockedRemoteMessage.swift
//  GoodRemoteNotifier-Sample
//
//  Created by Marek Vríčan on 26/09/2025.
//

import GoodRemoteNotifier
import Foundation

// Let's say this is our JSON from remoteConfig:
/// {
///   "current_version": "3.6.0",
///   "title": {
///     "en": "An Update is Available!",
///     "de": "Ein Update ist verfügbar!",
///     "es": "¡Una actualización está disponible!"
///   },
///   "message": {
///     "en": "The new version of the app is here, bringing a range of improvements to enhance your experience.",
///     "de": "Die neue Version der App ist da und bringt zahlreiche Verbesserungen, die Ihr Erlebnis optimieren.",
///     "es": "La nueva versión de la aplicación ya está aquí, con una serie de mejoras para mejorar tu experiencia."
///   },
///   "updateButton": {
///     "en": "Update Now",
///     "de": "Jetzt aktualisieren",
///     "es": "Actualizar ahora"
///   },
///   "closeButton": {
///     "en": "Close",
///     "de": "Schließen",
///     "es": "Cerrar"
///   }
/// }
// Now, the RemoteMessage bridges what's coming from the RemoteConfig and what we expect to show
// in the app(LocalizedRemoteMessage)
// There title and message cannot be nil, otherwise no message will be present.
// You can also set the frequency how often you wanna show the message.


struct MockedRemoteMessage: RemoteMessage, Codable, Sendable {

    let title, message: [String: String]
    let updateButton, closeButton: [String: String]

    func localizedMessage() async -> LocalizedRemoteMessage? {
        let availableLanguageCodes = title.keys
        let localLanguageCode = Locale.preferredLanguages.first?
            .split(separator: "-")
            .first
            .map(String.init) ?? "en"

        let languageCode = availableLanguageCodes.first { $0 == localLanguageCode } ?? "en"

        return LocalizedRemoteMessage(
            title: title[languageCode],
            message: message[languageCode],
            updateButton: updateButton[languageCode],
            closeButton: closeButton[languageCode],
            frequency: .always
        )
    }

    func shouldShowMessage() async -> Bool { true }

    static var sample: MockedRemoteMessage {
        .init(
            title: [
                "en": "An Update is Available!",
                "de": "Ein Update ist verfügbar!",
                "es": "¡Una actualización está disponible!"
            ],
            message: [
                "en": "The new version of the app is here, bringing a range of improvements to enhance your experience.",
                "de": "Die neue Version der App ist da und bringt zahlreiche Verbesserungen, die Ihr Erlebnis optimieren.",
                "es": "La nueva versión de la aplicación ya está aquí, con una serie de mejoras para mejorar tu experiencia."
            ],
            updateButton: [
                "en": "Update Now",
                "de": "Jetzt aktualisieren",
                "es": "Actualizar ahora"
            ],
            closeButton: [
                "en": "Close",
                "de": "Schließen",
                "es": "Cerrar"
            ]
        )
    }
}
