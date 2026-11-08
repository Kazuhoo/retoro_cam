import SwiftUI

/// カメラの見た目＝撮影画面の色（spec §5 の表）
struct CameraTheme {
    let name: String
    let body: Color
    let text: Color
    let sub: Color
    let button: Color
    let accent: Color
    let onAccent: Color
    let dot: Color
    let band: Color
    let stripes: [Color]
}

extension CameraID {
    var theme: CameraTheme {
        switch self {
        case .sunshine:
            CameraTheme(name: "SUNDAY 400", body: Color(hex: 0xF2B42A), text: Color(hex: 0x1F2440),
                        sub: Color(hex: 0x3A3320), button: Color(hex: 0x24315E), accent: Color(hex: 0x24315E),
                        onAccent: Color(hex: 0xF7D24A), dot: Color(hex: 0xD9452B), band: Color(hex: 0x24315E),
                        stripes: [Color(hex: 0xF7D24A), Color(hex: 0xEE8A2B), Color(hex: 0xD9452B)])
        case .charcoal:
            CameraTheme(name: "NOIR 1600", body: Color(hex: 0x1C1B19), text: Color(hex: 0xF2EDE4),
                        sub: Color(hex: 0xA39E93), button: Color(hex: 0x2B2925), accent: Color(hex: 0xF08A24),
                        onAccent: Color(hex: 0x1C1B19), dot: Color(hex: 0xF08A24), band: Color(hex: 0x2B2925),
                        stripes: [Color(hex: 0xF08A24)])
        case .pool:
            CameraTheme(name: "SPLASH 200", body: Color(hex: 0x2E5FB4), text: Color(hex: 0xFFFFFF),
                        sub: Color(hex: 0xDCE8F7), button: Color(hex: 0x1F3F80), accent: Color(hex: 0xF6D343),
                        onAccent: Color(hex: 0x1F2A44), dot: Color(hex: 0xF6D343), band: Color(hex: 0x9CCBEA),
                        stripes: [Color(hex: 0xF4F1E6)])
        case .green:
            CameraTheme(name: "ALBUM 100", body: Color(hex: 0x3F8A45), text: Color(hex: 0xFFFFFF),
                        sub: Color(hex: 0xE3EFE3), button: Color(hex: 0x161616), accent: Color(hex: 0xC8352B),
                        onAccent: Color(hex: 0xFFFFFF), dot: Color(hex: 0xF4F1E6), band: Color(hex: 0x161616),
                        stripes: [Color(hex: 0xF4F1E6), Color(hex: 0xC8352B)])
        case .party:
            CameraTheme(name: "NITE 800", body: Color(hex: 0x151515), text: Color(hex: 0xF7E9F1),
                        sub: Color(hex: 0xC9A9BD), button: Color(hex: 0x2A2A2A), accent: Color(hex: 0xFF4FA3),
                        onAccent: Color(hex: 0x151515), dot: Color(hex: 0xFF4FA3), band: Color(hex: 0x2A2A2A),
                        stripes: [Color(hex: 0xFF4FA3)])
        }
    }
}
