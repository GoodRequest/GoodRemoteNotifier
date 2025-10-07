//
//  RemoteConfigClient.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 11/09/2025.
//

import Foundation

public final class RemoteConfigClient: @unchecked Sendable {

    // MARK: - Errors

    enum RemoteConfigError: Error, LocalizedError {
        case missingGoogleServiceInfo
        case missingEntries
        case missingEntry(String)
        case noRefreshToken
        case authFailedAfterRetry
        case invalidURL(String)
        case unexpectedError(String)

        var errorDescription: String? {
            switch self {
            case .missingGoogleServiceInfo: "Failed to load GoogleServiceInfo"
            case .missingEntries: "Remote config response missing 'entries'"
            case .missingEntry(let key): "Remote config entry '\(key)' not found"
            case .noRefreshToken: "No refresh token available"
            case .authFailedAfterRetry: "Auth failed even after refresh. Tokens cleared."
            case .invalidURL(let url): "Invalid URL: \(url)"
            case .unexpectedError(let msg): "Unexpected error: \(msg)"
            }
        }
    }

    // MARK: - Structs

    struct Constants {

        static let fidKey = "fid"
        static let authTokenKey = "f_auth_token"
        static let refreshTokenKey = "f_refresh_token"
        static let lastFetchKey = "remote_config_last_fetch"
        static let cachedConfigKey = "remote_config_cached_data"

    }

    public struct Configuration: Sendable {

        let serviceInfo: GoogleServiceInfo
        let fetchInterval: TimeInterval

        public init?(serviceInfo: GoogleServiceInfo? = .load(), fetchInterval: TimeInterval = 43_200) {
            guard let serviceInfo else { return nil }

            self.serviceInfo = serviceInfo
            self.fetchInterval = fetchInterval
        }

    }

    // MARK: - Properties

    private let configuration: Configuration
    private let session = URLSession.shared
    private let decoder = JSONDecoder()

    private var installationsID: String? {
        UserDefaults.standard.string(forKey: Constants.fidKey)
    }

    private var authToken: String? {
        UserDefaults.standard.string(forKey: Constants.authTokenKey)
    }

    private var refreshToken: String? {
        UserDefaults.standard.string(forKey: Constants.refreshTokenKey)
    }

    private var lastFetchDate: Date? {
        get { UserDefaults.standard.object(forKey: Constants.lastFetchKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Constants.lastFetchKey) }
    }

    private var cachedConfigData: Data? {
        get { UserDefaults.standard.data(forKey: Constants.cachedConfigKey) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.cachedConfigKey) }
    }

    // MARK: - Initializer

    init(configuration: Configuration?) throws {
        guard let configuration else {
            throw RemoteConfigError.missingGoogleServiceInfo
        }
        self.configuration = configuration
    }

}

// MARK: - Cache Helpers

private extension RemoteConfigClient {

    func saveInstallationToCache(_ response: InstallationResponse) {
        UserDefaults.standard.set(response.fid, forKey: Constants.fidKey)
        UserDefaults.standard.set(response.authToken.token, forKey: Constants.authTokenKey)
        UserDefaults.standard.set(response.refreshToken, forKey: Constants.refreshTokenKey)
    }

    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: Constants.fidKey)
        UserDefaults.standard.removeObject(forKey: Constants.authTokenKey)
        UserDefaults.standard.removeObject(forKey: Constants.refreshTokenKey)
    }

}

// MARK: - Auth Token

private extension RemoteConfigClient {

    private func requireAuthToken() async throws -> FirebaseAuthConfig {
        if let fid = installationsID, let token = authToken, refreshToken != nil {
            return FirebaseAuthConfig(installationsID: fid, authToken: token)
        }
        return try await initializeInstallation()
    }

    private func initializeInstallation() async throws -> FirebaseAuthConfig {
        let request = try RequestBuilder
            .createInstallation(payload: .init(appId: configuration.serviceInfo.appID))
            .build(with: configuration.serviceInfo)

        let (data, _) = try await session.data(for: request)
        let response = try decoder.decode(InstallationResponse.self, from: data)
        saveInstallationToCache(response)
        return FirebaseAuthConfig(installationsID: response.fid, authToken: response.authToken.token)
    }

    private func refreshAuthToken(fid: String, refreshToken: String) async throws -> FirebaseAuthConfig {
        let request = try RequestBuilder
            .generateAuthToken(fid: fid, refreshToken: refreshToken)
            .build(with: configuration.serviceInfo)

        let (data, _) = try await session.data(for: request)
        let response = try decoder.decode(InstallationResponse.AuthToken.self, from: data)
        UserDefaults.standard.set(response.token, forKey: Constants.authTokenKey)
        return FirebaseAuthConfig(installationsID: fid, authToken: response.token)
    }

}

// MARK: - Fetch Remote Config (with throttling & caching)

extension RemoteConfigClient {

    func fetchRemoteConfig(for key: String) async throws -> Data {
        // Check interval — if too soon, return cached data
        if let last = lastFetchDate, Date().timeIntervalSince(last) < configuration.fetchInterval {
            if let cached = cachedConfigData {
                return try parseRemoteConfig(inputData: cached, key: key)
            }
        }

        var authConfig = try await requireAuthToken()
        let maxAttempts = 2
        var attempts = 0

        func makeRequest(with token: String) throws -> URLRequest {
            let requestBody = FetchRequestBody(
                appInstanceId: authConfig.installationsID,
                appId: configuration.serviceInfo.appID,
                appInstanceIdToken: token
            )
            return try RequestBuilder.fetchRemoteConfig(payload: requestBody).build(with: configuration.serviceInfo)
        }

        while attempts < maxAttempts {
            let (data, response) = try await session.data(for: makeRequest(with: authConfig.authToken))

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                attempts += 1
                if attempts >= maxAttempts {
                    clearTokens()
                    throw RemoteConfigError.authFailedAfterRetry
                }
                guard let refresh = refreshToken else {
                    throw RemoteConfigError.noRefreshToken
                }
                authConfig = try await refreshAuthToken(fid: authConfig.installationsID, refreshToken: refresh)
                continue
            }

            cachedConfigData = data
            lastFetchDate = Date()

            return try parseRemoteConfig(inputData: data, key: key)
        }

        throw RemoteConfigError.unexpectedError("Reached unreachable code in fetchRemoteConfig")
    }

    // MARK: - Parse Remote Config

    private func parseRemoteConfig(inputData data: Data, key: String) throws -> Data {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

        guard let entries = json["entries"] as? [String: Any] else {
            throw RemoteConfigError.missingEntries
        }
        guard let filteredEntry = entries[key] else {
            throw RemoteConfigError.missingEntry(key)
        }

        return (filteredEntry as? String)?.data(using: .utf8) ?? .init()
    }

}
