//
//  MessageManager.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 16/04/2025.
//

import Foundation

/// A manager responsible for handling the display frequency of remote messages.
internal final class MessageManager {

    /// The shared `UserDefaults` instance for storing message timestamps.
    private let userDefaults = UserDefaults.standard

    /// The key prefix used for storing message timestamps.
    private static let updateMessageKey = "UpdateMessageKey_"

    /// Determines whether a given message should be shown based on its frequency and last shown timestamp.
    /// - Parameter message: The `LocalizedRemoteMessage` to check.
    /// - Returns: A Boolean indicating whether the message should be displayed.
    internal func shouldShowMessage(_ message: LocalizedRemoteMessage) -> Bool {
        let lastShownKey = "\(Self.updateMessageKey)\(message.id)"
        let now = Date()

        if let lastShownDate = userDefaults.object(forKey: lastShownKey) as? Date {
            switch message.frequency {
            case .once:
                return false

            case .daily:
                return !Calendar.current.isDate(lastShownDate, inSameDayAs: now)

            case .weekly:
                return !Calendar.current.isDate(lastShownDate, equalTo: now, toGranularity: .weekOfYear)

            case .monthly:
                return !Calendar.current.isDate(lastShownDate, equalTo: now, toGranularity: .month)
            }
        }

        return true
    }

    /// Marks a message as shown by saving the current timestamp in `UserDefaults`.
    /// - Parameter message: The `LocalizedRemoteMessage` to mark as shown.
    internal func markMessageAsShown(_ message: LocalizedRemoteMessage) {
        deleteOldMessages()
        let lastShownKey = "\(Self.updateMessageKey)\(message.id)"
        userDefaults.set(Date(), forKey: lastShownKey)
    }

    /// Removes outdated message timestamps from `UserDefaults` to prevent storage clutter.
    private func deleteOldMessages() {
        let keysToRemove = userDefaults.dictionaryRepresentation().keys.filter { $0.contains(Self.updateMessageKey) }
        for key in keysToRemove {
            userDefaults.removeObject(forKey: key)
        }
    }
}

