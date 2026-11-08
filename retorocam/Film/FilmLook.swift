import Foundation

/// カメラ5台のID（spec.md の表のとおり）
nonisolated enum CameraID: String, CaseIterable, Sendable {
    case sunshine, charcoal, pool, green, party

    var look: FilmLook {
        switch self {
        case .sunshine: FilmLook(lutName: "SUNDAY_400", grain: 0.030, grainSize: 1.4, vignette: 0.28)
        case .charcoal: FilmLook(lutName: "NOIR_1600", grain: 0.060, grainSize: 2.0, vignette: 0.38)
        case .pool: FilmLook(lutName: "SPLASH_200", grain: 0.020, grainSize: 1.2, vignette: 0.18)
        case .green: FilmLook(lutName: "ALBUM_100", grain: 0.016, grainSize: 1.0, vignette: 0.30)
        case .party: FilmLook(lutName: "NITE_800", grain: 0.045, grainSize: 1.7, vignette: 0.42)
        }
    }
}

nonisolated struct FilmLook: Sendable {
    /// バンドル内の .cube ファイル名（拡張子なし）
    let lutName: String
    let grain: Float
    let grainSize: CGFloat
    let vignette: Float
}

/// 撮った瞬間の設定。あとから設定を変えても撮影済みの写真は変わらない。
nonisolated struct CaptureOptions: Sendable {
    var dateStamp = true
    var lightLeak = false
}
