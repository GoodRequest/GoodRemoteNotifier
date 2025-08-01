//
//  RemoteMessage.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 17/04/2025.
//

public protocol RemoteMessage: Codable {

    func localizedMessage() async -> LocalizedRemoteMessage?

    func shouldShowMessage() async -> Bool

}

public extension RemoteMessage {

    func shouldShowMessage() async -> Bool { true }
    
}
