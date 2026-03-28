import Foundation
#if canImport(UIKit)
import UIKit
#endif
import Darwin

struct DeviceInfo {
    let model: String
    let osVersion: String
    let screenWidth: Int
    let screenHeight: Int
    let platform: String

    static var current: DeviceInfo {
        DeviceInfo(
            model: modelIdentifier(),
            osVersion: osVersionString(),
            screenWidth: screenWidthPoints(),
            screenHeight: screenHeightPoints(),
            platform: platformString()
        )
    }

    private static func modelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }

    private static func osVersionString() -> String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
    }

    private static func screenWidthPoints() -> Int {
        #if canImport(UIKit)
        return Int(UIScreen.main.bounds.width)
        #else
        return 0
        #endif
    }

    private static func screenHeightPoints() -> Int {
        #if canImport(UIKit)
        return Int(UIScreen.main.bounds.height)
        #else
        return 0
        #endif
    }

    private static func platformString() -> String {
        #if targetEnvironment(macCatalyst)
        return "macos"
        #elseif canImport(UIKit)
        return "ios"
        #else
        return "macos"
        #endif
    }
}
