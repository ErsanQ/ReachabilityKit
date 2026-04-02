#if canImport(SwiftUI)
import Foundation
import SwiftUI

#if canImport(Network)
import Network
#endif

/// The type of network connection detected by `ReachabilityKit`.
public enum ConnectionType: String, Sendable {
    /// Connected via a WiFi network.
    case wifi = "WiFi"
    /// Connected via a cellular data network.
    case cellular = "Cellular"
    /// Connected via a wired Ethernet cable.
    case wired = "Wired"
    /// Connected via another interface (e.g., VPN, Bluetooth).
    case other = "Other"
    /// No active internet connection.
    case none = "No Connection"
}

/// A simplified, modern network observer designed for SwiftUI applications.
///
/// `Reachability` provides a real-time stream of connectivity updates using Apple's `Network` framework.
/// It is optimized for the ErsanQ ecosystem with automatic @MainActor updates for UI safety.
///
/// ## Usage
/// ```swift
/// @StateObject private var reachability = Reachability.shared
/// 
/// var body: some View {
///     if reachability.isConnected {
///         MainView()
///     } else {
///         OfflineView()
///     }
/// }
/// ```
@MainActor
public final class Reachability: ObservableObject {
    
    /// The shared instance of `Reachability`.
    public static let shared = Reachability()
    
    #if canImport(Network)
    private let monitor = NWPathMonitor()
    #endif
    private let queue = DispatchQueue(label: "ReachabilityKitQueue")
    
    /// A boolean value indicating whether the internet is currently reachable.
    @Published public private(set) var isConnected: Bool = true
    
    /// The current type of network connection (WiFi, Cellular, etc.).
    @Published public private(set) var connectionType: ConnectionType = .none
    
    private init() {
        #if canImport(Network)
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.mapConnectionType(path) ?? .none
            }
        }
        monitor.start(queue: queue)
        #endif
    }
    
    #if canImport(Network)
    private func mapConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.cellular) { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .wired }
        if path.status == .satisfied { return .other }
        return .none
    }
    #endif
}

public extension View {
    /// Responds to changes in network connectivity.
    ///
    /// Use this modifier to trigger actions (like toast notifications or data refreshing) 
    /// whenever the internet connection status changes.
    ///
    /// - Parameter perform: A closure to execute when the connection status changes.
    /// - Returns: A view that observes network status and triggers the provided closure.
    func onNetworkChange(perform: @escaping (Bool) -> Void) -> some View {
        self.modifier(NetworkObserverModifier(perform: perform))
    }
}

/// An internal ViewModifier that bridges `Reachability` updates to a closure.
private struct NetworkObserverModifier: ViewModifier {
    @ObservedObject private var monitor = Reachability.shared
    let perform: (Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .onChange(of: monitor.isConnected) { newValue in
                perform(newValue)
            }
    }
}
#endif
