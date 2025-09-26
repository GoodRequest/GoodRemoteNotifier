//
//  FirebaseResponses.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 26/09/2025.
//

struct InstallationResponse: Decodable {

    let fid: String
    let authToken: AuthToken
    let refreshToken: String

    struct AuthToken: Decodable {
        let token: String
    }

}
