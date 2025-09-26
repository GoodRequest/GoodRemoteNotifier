//
//  SwiftUIExtensions.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 17/04/2025.
//

import Foundation

internal extension Bundle {

    /// Retrieves the last icon file name from the app's primary icon settings in the Info.plist.
    /// - Returns: The name of the last icon file in the array of icon files, or `nil` if not found.
    var iconFileName: String? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return nil }

        return iconFileName
    }

    func fileURL(withName name: String, extension fileExtension: String) -> URL? {
        self.urls(forResourcesWithExtension: fileExtension, subdirectory: nil)?
            .first(where: { $0.lastPathComponent == "\(name).\(fileExtension)" })
    }

}
