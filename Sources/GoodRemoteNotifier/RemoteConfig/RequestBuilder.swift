//
//  RequestBuilder.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 11/09/2025.
//

import Foundation

enum RequestBuilder {

    // MARK: - Constants

    enum Constants {

        static let installationsBase = "https://firebaseinstallations.googleapis.com/v1/projects"
        static let remoteConfigBase = "https://firebaseremoteconfig.googleapis.com/v1/projects"
        static let installationsAuthVersion = "FIS_v2"

    }

    // MARK: - Request Types

    case createInstallation(payload: InstallationRequestBody)
    case fetchRemoteConfig(payload: FetchRequestBody)
    case generateAuthToken(fid: String, refreshToken: String)

    // MARK: - HTTP Method

    var method: String { "POST" }

    // MARK: - Request Body
    var body: Data? {
        switch self {
        case .createInstallation(let payload): try? payload.toData()
        case .fetchRemoteConfig(let payload): try? payload.toData()
        case .generateAuthToken: Data()
        }
    }

    // MARK: - Build URLRequest
    func build(with config: GoogleServiceInfo) throws -> URLRequest {
        let projectID = config.projectID
        let apiKey = config.apiKey

        // Full URL
        let urlString: String = switch self {
        case .createInstallation:
            "\(Constants.installationsBase)/\(projectID)/installations?key=\(apiKey)"

        case .fetchRemoteConfig:
            "\(Constants.remoteConfigBase)/\(projectID)/namespaces/firebase:fetch?key=\(apiKey)"

        case .generateAuthToken(let fid, _):
            "\(Constants.installationsBase)/\(projectID)/installations/\(fid)/authTokens:generate?key=\(apiKey)"
        }

        // Build request
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        // Add authorization header for auth token refresh
        if case .generateAuthToken(_, let refreshToken) = self {
            request.setValue("\(Constants.installationsAuthVersion) \(refreshToken)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

}

fileprivate extension Encodable {

    func toData() throws -> Data {
        try JSONEncoder().encode(self)
    }

}
