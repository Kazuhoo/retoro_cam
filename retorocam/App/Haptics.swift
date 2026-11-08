import UIKit

/// spec §14 のハプティクス。設定での ON/OFF は M5。
enum Haptics {
    private static let rigid = UIImpactFeedbackGenerator(style: .rigid)
    private static let lightIntensity: CGFloat = 0.4

    static func windTick() { rigid.impactOccurred(intensity: lightIntensity) }
    static func windComplete() { rigid.impactOccurred(intensity: 1.0) }
    static func flashSwitch() { rigid.impactOccurred(intensity: lightIntensity) }
}
