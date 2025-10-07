//
//  NetworkReachabilityManager.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 26/09/2025.
//

import Network

actor NetworkReachabilityManager {

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkReachabilityQueue")

    private var wasReachable = false
    private var continuation: AsyncStream<Void>.Continuation?

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            Task { [weak self] in await self?.handlePathUpdate(path.status == .satisfied) }
        }
        monitor.start(queue: queue)
    }

    func reachabilityStream() -> AsyncStream<Void> {
        AsyncStream { self.continuation = $0 }
    }

    private func handlePathUpdate(_ isReachable: Bool) {
        if isReachable && !wasReachable {
            continuation?.yield(())
        }
        wasReachable = isReachable
    }

    deinit {
        monitor.cancel()
        continuation?.finish()
    }

}
