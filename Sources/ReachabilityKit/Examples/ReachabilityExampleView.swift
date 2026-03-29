import SwiftUI
import ReachabilityKit

struct ReachabilityExampleView: View {
    @StateObject private var network = Reachability.shared
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: network.isConnected ? "wifi" : "wifi.slash")
                .font(.system(size: 80))
                .foregroundColor(network.isConnected ? .green : .red)
            
            VStack(spacing: 12) {
                Text(network.isConnected ? "Internet Connection Active" : "No Internet Connection")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(network.isConnected ? "Type: \(network.connectionType.rawValue)" : "Please check your network settings")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            StatusIndicator(isConnected: network.isConnected)
            
            Spacer()
            
            Text("Try toggling Airplane Mode to see changes in real-time.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .navigationTitle("ReachabilityKit Demo")
        .onNetworkChange { isConnected in
            if !isConnected {
                showAlert = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Connectivity Lost"), message: Text("You are now offline."), dismissButton: .default(Text("OK")))
        }
    }
}

struct StatusIndicator: View {
    let isConnected: Bool
    var body: some View {
        HStack {
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            Text(isConnected ? "Online" : "Offline")
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isConnected ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        .cornerRadius(20)
    }
}

#Preview {
    NavigationView {
        ReachabilityExampleView()
    }
}
