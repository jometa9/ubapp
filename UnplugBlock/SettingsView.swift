import SwiftUI

struct SettingsView: View {
    @State private var customDelay: Double = 3.0
    @State private var enableAdvancedNotifications = false
    @State private var enableAutoStart = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Image(systemName: "gear")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Delay")
                        .font(.headline)
                    
                    HStack {
                        Slider(value: $customDelay, in: 1...10, step: 0.5)
                        
                        Text("\(customDelay, specifier: "%.1f")s")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Wait time before logging out when charger is disconnected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Advanced Notifications")
                        .font(.headline)
                    
                    Toggle("Show detailed notifications", isOn: $enableAdvancedNotifications)
                    
                    Text("Show additional information in notifications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Auto Start")
                        .font(.headline)
                    
                    Toggle("Run at login", isOn: $enableAutoStart)
                    
                    Text("UnplugBlock will run automatically when you log in")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("UnplugBlock v1.0")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("Monitors charger status and automatically logs out when disconnected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Developed to maintain your Mac's security")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 500)
    }
}

#Preview {
    SettingsView()
}
