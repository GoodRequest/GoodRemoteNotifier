//
//  GoogleServiceInfo.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 26/09/2025.
//

import Foundation

public struct GoogleServiceInfo: Decodable & Sendable {

    let apiKey: String
    let appID: String
    let projectID: String

    enum CodingKeys: String, CodingKey {

        case apiKey = "API_KEY"
        case appID = "GOOGLE_APP_ID"
        case projectID = "PROJECT_ID"

    }

    static var mock: Self { .init(apiKey: "key", appID: "id", projectID: "id") }

    public static func load(plistName: String = "GoogleService-Info") -> GoogleServiceInfo? {
        guard let url = Bundle.main.fileURL(withName: plistName, extension: "plist"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Could not find \(plistName).plist in bundle")

            return nil
        }

        do {
            let info = try PropertyListDecoder().decode(GoogleServiceInfo.self, from: data)
            return info
        } catch {
            print("❌ Failed to decode plist: \(error)")
            return nil
        }
    }

}
