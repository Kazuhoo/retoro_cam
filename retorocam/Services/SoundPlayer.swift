import AVFoundation

/// 効果音（シャッター音は iOS 標準なのでここには含めない）。
/// 素材は Resources/Sounds のファイル名だけで差し替えられる。
enum SoundPlayer {
    enum Sound: String, CaseIterable {
        case windTick = "wind_tick"
        case windComplete = "wind_complete"
        case flashSwitch = "flash_switch"
        case envelopeFlap = "envelope_flap"
        case packTear = "pack_tear"
    }

    /// 設定の「巻き上げ音・効果音」（AppSettings が更新する）
    static var isEnabled = true

    private static var players: [Sound: AVAudioPlayer] = [:]
    private static let extensions = ["wav", "caf", "m4a", "mp3"]

    /// 起動時に読み込む。消音モードに従い、音楽は止めない
    static func prepare() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        for sound in Sound.allCases {
            let url = extensions.lazy.compactMap { Bundle.main.url(forResource: sound.rawValue, withExtension: $0) }.first
            guard let url, let player = try? AVAudioPlayer(contentsOf: url) else { continue }
            player.prepareToPlay()
            players[sound] = player
        }
    }

    static func play(_ sound: Sound) {
        guard isEnabled, let player = players[sound] else { return }
        player.currentTime = 0
        player.play()
    }
}
