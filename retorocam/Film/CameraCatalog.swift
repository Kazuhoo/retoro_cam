import SwiftUI

/// カメラを選ぶ・買う画面で見せる内容
struct CameraProfile {
    let summary: LocalizedStringKey
    let detail: LocalizedStringKey
    /// 作例の仮の色（M7 で実際の写真に差し替える）
    let samples: [(light: Color, dark: Color)]
    let packText: Color
}

extension CameraID {
    var profile: CameraProfile {
        switch self {
        case .sunshine:
            CameraProfile(summary: "日曜日のあたたかい色。90年代の写真屋プリント",
                          detail: "日曜日のあたたかい色。90年代の写真屋プリント",
                          samples: Self.colors([(0xC49A5C, 0x3E2E1E), (0xA38E62, 0x33301F), (0xC0855A, 0x3C2A1E)]),
                          packText: theme.text)
        case .charcoal:
            CameraProfile(summary: "粒子の粗い、70年代のモノクロ",
                          detail: "粒子の粗い、70年代のモノクロ。路地裏や報道写真のような、黒の締まった写り。",
                          samples: Self.colors([(0xA0A0A0, 0x141414), (0x7E7E7E, 0x101010), (0xB8B8B8, 0x1A1A1A)]),
                          packText: Color(hex: 0xF2EDE4))
        case .pool:
            CameraProfile(summary: "明るく青みがかった、夏の色",
                          detail: "明るく青みがかった、夏の色。海やプールなど、晴れた日の屋外に。",
                          samples: Self.colors([(0xC4E0E8, 0x5A8496), (0xB4D8E2, 0x4E7A8C), (0xD2E6E4, 0x6A8E96)]),
                          packText: .white)
        case .green:
            CameraProfile(summary: "少し色あせた、家族アルバム",
                          detail: "少し色あせた、80年代の家族アルバム。肌がやわらかく写ります。",
                          samples: Self.colors([(0xA3AE8E, 0x454C3A), (0xB2A88E, 0x4C463A), (0x94A68C, 0x3E4A3A)]),
                          packText: .white)
        case .party:
            CameraProfile(summary: "フラッシュで夜を撮る",
                          detail: "フラッシュで夜を撮る。被写体が白く光り、背景は暗く沈む、90年代の飲み会の写真。",
                          samples: Self.colors([(0xF0C2B0, 0x080808), (0xE8A8A0, 0x050505), (0xF4D0C0, 0x0A0A0A)]),
                          packText: Color(hex: 0xF7E9F1))
        }
    }

    /// カメラの絵と袋の色。NOIR だけ、暗い背景に沈まないよう別の値を使う
    var illustrationBody: Color { self == .charcoal ? Color(hex: 0x2A2825) : theme.body }
    var illustrationBand: Color { self == .charcoal ? Color(hex: 0x1A1917) : theme.band }

    private static func colors(_ pairs: [(UInt32, UInt32)]) -> [(light: Color, dark: Color)] {
        pairs.map { (Color(hex: $0.0), Color(hex: $0.1)) }
    }
}
