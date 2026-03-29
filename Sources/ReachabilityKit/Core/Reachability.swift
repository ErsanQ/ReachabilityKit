import Foundation
import Network
import SwiftUI

/// Connection type detected by `ReachabilityKit`.
public enum ConnectionType: String, Sendable {
    case wifi = "WiFi"
    case cellular = "Cellular"
    case wired = "Wired"
    case other = "Other"
    case none = "No Connection"
}

/// A simplified network observer for SwiftUI apps.
@MainActor
public final class Reachability: ObservableObject {
    
    /// The shared instance of `Reachability`.
    public static let shared = Reachability()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ReachabilityKitQueue")
    
    /// A boolean value indicating whether the internet is currently reachable.
    @Published public private(set) var isConnected: Bool = true
    
    /// The current type of network connection.
    @Published public private(set) var connectionType: ConnectionType = .none
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.mapConnectionType(path) ?? .none
            }
        }
        monitor.start(queue: queue)
    }
    
    private func mapConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.cellular) { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .wired }
        if path.status == .satisfied { return .other }
        return .none
    }
}

public extension View {
    /// Responds to changes in network connectivity.
    /// - Parameter perform: A closure to execute when the connection status changes.
    /// - Returns: A view that observes network status.
    func onNetworkChange(perform: @escaping (Bool) -> Void) -> some View {
        self.modifier(NetworkObserverModifier(perform: perform))
    }
}

private struct NetworkObserverModifier: ViewModifier {
    @StateObject private var monitor = Reachability.shared
    let perform: (Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .onChange(of: monitor.isConnected) { newValue in
                perform(newValue)
            }
    }
}
