import Cocoa
import IOKit.pwr_mgt

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBarItem: NSStatusItem!
    var powerMonitor: PowerMonitor!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        NSApp.setActivationPolicy(.accessory)
        
        setupPowerMonitor()
        
        // Initialize icon with real charger status
        let isConnected = powerMonitor.isChargerConnected()
        updateStatusBarIcon(connected: isConnected)
        
        // Setup menu after powerMonitor is ready
        DispatchQueue.main.async {
            self.setupMenu()
        }
    }
    
    private func requestPermissions() {
        let alert = NSAlert()
        alert.messageText = "UnplugBlock - Permission Setup"
        alert.informativeText = """
        UnplugBlock needs special permissions to work:
        
        1. Automation (to log out session)
        2. System Events access
        
        System Preferences will open next.
        Please grant the requested permissions.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Continue")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openSystemPreferences()
        }
    }
    
    private func openSystemPreferences() {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"]
        
        do {
            try task.run()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showPermissionInstructions()
            }
        } catch {
        }
    }
    
    private func showPermissionInstructions() {
        let alert = NSAlert()
        alert.messageText = "Permission Setup"
        alert.informativeText = """
        In System Preferences:
        
        1. Go to "Privacy & Security" → "Automation"
        2. Find "UnplugBlock" in the list
        3. Enable permissions for "System Events"
        4. If UnplugBlock doesn't appear, try disconnecting charger to trigger the request
        
        Once configured, UnplugBlock will work automatically!
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Got it")
        alert.runModal()
    }
    
    private func setupPowerMonitor() {
        powerMonitor = PowerMonitor()
        powerMonitor.delegate = self
        powerMonitor.startMonitoring()
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        let chargerStatus = powerMonitor?.isChargerConnected() ?? false ? "Connected" : "Disconnected"
        let statusItem = NSMenuItem(title: "Charger: \(chargerStatus)", action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)
        
        menu.addItem(NSMenuItem.separator())
        
        if !hasRequiredPermissions() {
            let permissionItem = NSMenuItem(title: "Allow Permissions", action: #selector(requestPermissionsManually), keyEquivalent: "")
            permissionItem.target = self
            menu.addItem(permissionItem)
            
            menu.addItem(NSMenuItem.separator())
        } else {
            let permissionItem = NSMenuItem(title: "Permissions OK", action: nil, keyEquivalent: "")
            permissionItem.isEnabled = false
            menu.addItem(permissionItem)
            
            menu.addItem(NSMenuItem.separator())
        }
        
        let quitItem = NSMenuItem(title: "Quit UnplugBlock", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusBarItem.menu = menu
    }
    
    private func updateMenu() {
        setupMenu()
    }
    
    private func hasRequiredPermissions() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "tell application \"System Events\" to get name"]
        task.standardOutput = Pipe()
        task.standardError = Pipe()
        
        do {
            try task.run()
            task.waitUntilExit()
            let hasPermissions = task.terminationStatus == 0
            return hasPermissions
        } catch {
            return false
        }
    }
    
    @objc private func requestPermissionsManually() {
        requestPermissions()
    }
    
    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "UnplugBlock - Optional Permissions"
        alert.informativeText = """
        UnplugBlock can work better with automation permissions.
        
        Current functionality:
        • Screen locking: Working
        • Advanced features: Configure permissions for more options
        
        Click 'Configure' to set up permissions.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Configure")
        alert.addButton(withTitle: "Later")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            requestPermissions()
        }
    }
    
    @objc func quitApp() {
        powerMonitor?.stopMonitoring()
        NSApplication.shared.terminate(nil)
    }
}

extension AppDelegate: PowerMonitorDelegate {
    func powerSourceChanged(isConnected: Bool) {
        DispatchQueue.main.async {
            if isConnected {
                self.updateStatusBarIcon(connected: true)
                self.updateMenu()
            } else {
                self.updateStatusBarIcon(connected: false)
                
                self.logoutUser()
            }
        }
    }
    
    private func updateStatusBarIcon(connected: Bool) {
        if let button = statusBarItem.button {
            let title = connected ? "B" : "U"
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.boldSystemFont(ofSize: 14),
                .baselineOffset: -1
            ]
            button.attributedTitle = NSAttributedString(string: title, attributes: attrs)
        }
    }
    
    private func logoutUser() {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["sleepnow"]
        
        do {
            try task.run()
        } catch {
        }
    }
}