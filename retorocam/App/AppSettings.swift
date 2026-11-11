import Foundation
import Observation

/// 設定画面の値（UserDefaults に保存する）
@Observable
final class AppSettings {
    private enum Key {
        static let dateStamp = "settings.dateStamp"
        static let lightLeak = "settings.lightLeak"
        static let sound = "settings.sound"
        static let haptics = "settings.haptics"
        static let hasSeenOnboarding = "settings.hasSeenOnboarding"
        static let launchCount = "settings.launchCount"
    }

    @ObservationIgnored private let defaults: UserDefaults

    var dateStamp: Bool { didSet { defaults.set(dateStamp, forKey: Key.dateStamp) } }
    var lightLeak: Bool { didSet { defaults.set(lightLeak, forKey: Key.lightLeak) } }
    /// 巻き上げ音・効果音（シャッター音は含まない）
    var sound: Bool {
        didSet {
            defaults.set(sound, forKey: Key.sound)
            SoundPlayer.isEnabled = sound
        }
    }
    var haptics: Bool {
        didSet {
            defaults.set(haptics, forKey: Key.haptics)
            Haptics.isEnabled = haptics
        }
    }
    var hasSeenOnboarding: Bool { didSet { defaults.set(hasSeenOnboarding, forKey: Key.hasSeenOnboarding) } }

    /// これまでの起動回数（今回を含む）
    private(set) var launchCount: Int

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        dateStamp = defaults.object(forKey: Key.dateStamp) as? Bool ?? true
        lightLeak = defaults.object(forKey: Key.lightLeak) as? Bool ?? false
        sound = defaults.object(forKey: Key.sound) as? Bool ?? true
        haptics = defaults.object(forKey: Key.haptics) as? Bool ?? true
        hasSeenOnboarding = defaults.bool(forKey: Key.hasSeenOnboarding)
        launchCount = defaults.integer(forKey: Key.launchCount)
        Haptics.isEnabled = haptics
        SoundPlayer.isEnabled = sound
    }

    func recordLaunch() {
        launchCount += 1
        defaults.set(launchCount, forKey: Key.launchCount)
    }
}
