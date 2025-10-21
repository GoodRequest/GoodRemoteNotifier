//
//  ImageExtensions.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 15/10/2025.
//

import SwiftUI

public extension Image {

    static let appIcon: Self? = Bundle.main.iconFileName
        .flatMap { UIImage(named: $0) }
        .map { Image(uiImage: $0) }

}
