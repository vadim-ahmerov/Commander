import AppKit
import ServiceManagement

final class AutoLaunchManager {
    func configureAutoLaunch(enabled: Bool) {
        let launcherAppID = "com.va.commander.launcher"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains {
            $0.bundleIdentifier == launcherAppID
        }

        SMLoginItemSetEnabled(launcherAppID as CFString, enabled)

        if isRunning {
            DistributedNotificationCenter.default()
                .post(name: .killLauncher, object: Bundle.main.bundleIdentifier!)
        }
    }
}
