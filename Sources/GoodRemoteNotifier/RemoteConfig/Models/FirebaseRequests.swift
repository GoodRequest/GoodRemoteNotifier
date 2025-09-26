//
//  FirebaseRequests.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 26/09/2025.
//

struct FirebaseAuthConfig {

    let installationsID: String
    let authToken: String

}

struct InstallationRequestBody: Encodable {

    var sdkVersion: String = "18.0.0"
    let appId: String

}

struct FetchRequestBody: Encodable {

    let appInstanceId: String
    let appId: String
    let appInstanceIdToken: String

    enum CodingKeys: String, CodingKey {

        case appInstanceId = "app_instance_id"
        case appId = "app_id"
        case appInstanceIdToken = "app_instance_id_token"

    }

}
