import Foundation
import SwiftUI
import UserNotifications

class DevelopmentTools: ObservableObject {
    static let shared = DevelopmentTools()
    
    @Published var isDevelopmentMode = false
    @Published var showDevelopmentPanel = false
    
    private init() {
        #if DEBUG
        isDevelopmentMode = true
        #endif
    }
    
    func simulateChargerDisconnect() {
        NotificationCenter.default.post(
            name: NSNotification.Name("SimulateChargerDisconnect"),
            object: nil
        )
    }
    
    func simulateChargerConnect() {
        NotificationCenter.default.post(
            name: NSNotification.Name("SimulateChargerConnect"),
            object: nil
        )
    }
    
    func simulateLogout() {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "tell application \"System Events\" to log out"]
        
        do {
            try task.run()
        } catch {
        }
    }
    
    func showTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "UnplugBlock - Test"
        content.body = "This is a test notification"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: "unplugblock-test-notification",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
            }
        }
    }
}

struct DevelopmentPanelView: View {
    @StateObject private var devTools = DevelopmentTools.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Development Tools")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Development Status")
                    .font(.headline)
                
                HStack {
                    Image(systemName: devTools.isDevelopmentMode ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(devTools.isDevelopmentMode ? .green : .red)
                    
                    Text(devTools.isDevelopmentMode ? "Development mode active" : "Development mode inactive")
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Testing Tools")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Charger Simulation")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 12) {
                        Button("Simulate Disconnect") {
                            devTools.simulateChargerDisconnect()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Simulate Connect") {
                            devTools.simulateChargerConnect()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notification Testing")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Button("Send Test Notification") {
                        devTools.showTestNotification()
                    }
                    .buttonStyle(.bordered)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Logout Testing")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Button("Simulate Logout") {
                        devTools.simulateLogout()
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(.red)
                }
            }
            .padding()
            
            Spacer()
            
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Warning")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Text("These tools are for development and testing only. Use with caution.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .frame(width: 400, height: 500)
    }
}

#Preview {
    DevelopmentPanelView()
}
