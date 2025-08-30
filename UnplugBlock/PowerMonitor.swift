import Foundation

protocol PowerMonitorDelegate: AnyObject {
    func powerSourceChanged(isConnected: Bool)
}

class PowerMonitor {
    weak var delegate: PowerMonitorDelegate?
    private var timer: Timer?
    private var lastState: Bool = true
    
    func startMonitoring() {
        lastState = isChargerConnected()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkPowerSource()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func isChargerConnected() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["-g", "ps"]
        task.standardOutput = Pipe()
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if let pipe = task.standardOutput as? Pipe {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                
                return output.contains("AC Power")
            }
        } catch {
        }
        
        return true
    }
    
    private func checkPowerSource() {
        let currentState = isChargerConnected()
        
        if currentState != lastState {
            lastState = currentState
            delegate?.powerSourceChanged(isConnected: currentState)
        }
    }
    
    deinit {
        stopMonitoring()
    }
}