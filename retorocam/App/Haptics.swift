import UIKit

/// spec §14 のハプティクス。
enum Haptics {
    private static let rigid = UIImpactFeedbackGenerator(style: .rigid)
    private static let lightIntensity: CGFloat = 0.4
    /// 設定の「振動」（AppSettings が更新する）
    static var isEnabled = true

    static func windTick() { play(lightIntensity) }
    static func windComplete() { play(1.0) }
    static func flashSwitch() { play(lightIntensity) }

    private static func play(_ intensity: CGFloat) {
        guard isEnabled else { return }
        rigid.impactOccurred(intensity: intensity)
    }
}
