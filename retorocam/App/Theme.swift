import SwiftUI

enum Theme {
    /// 撮影画面以外でも使う共通の暗い配色
    enum Common {
        static let background = Color(hex: 0x1C1B19)
        static let text = Color(hex: 0xF2EDE4)
    }

    /// 撮影画面の配置（モックアップ 844×390 の値）
    enum Layout {
        static let topPadding: CGFloat = 32
        static let bottomPadding: CGFloat = 20
        static let minBottomPadding: CGFloat = 8
        static let horizontalPadding: CGFloat = 24
        static let columnGap: CGFloat = 24
        static let columnWidth: CGFloat = 218
        static let columnTopPadding: CGFloat = 14
        static let nameTop: CGFloat = 6
        static let nameLeading: CGFloat = 6
        static let shutterHintTop: CGFloat = 9
        static let shutterHintTrailing: CGFloat = 150
        static let stripeHeight: CGFloat = 3
        static let stripesTotalHeight: CGFloat = 16
        static let iconSize: CGFloat = 44
    }

    enum Text {
        static let name = Font.system(size: 16, weight: .bold)   // M7 でカメラごとの書体に
        static let exposure = Font.system(size: 15, design: .monospaced)   // M7 で VT323 に
        static let hint = Font.system(size: 11)
        static let hintBold = Font.system(size: 11, weight: .bold)
        static let small = Font.system(size: 10)
        static let smallBold = Font.system(size: 10, weight: .bold)
        static let status = Font.system(size: 13)
        static let develop = Font.system(size: 15, weight: .bold)
        static let counter = Font.system(size: 20, design: .monospaced)   // M7 で VT323 に
    }

    enum Status {
        static let readyDot = Color(hex: 0x7BC47F)
        static let dotSize: CGFloat = 9
        static let developHeight: CGFloat = 48
        static let developPadding: CGFloat = 28
    }

    enum Viewfinder {
        static let maxWidth: CGFloat = 507
        static let maxHeight: CGFloat = 338
        static let cornerRadius: CGFloat = 14
        static let ringWidth: CGFloat = 2
        static let ringColor = Color(hex: 0x2E2C27)
        static let markColor = Color(hex: 0xE9E3D7)
        static let markSize: CGFloat = 18
        static let markInsetX: CGFloat = 16
        static let markInsetY: CGFloat = 14
        static let darkSignalDuration = 0.08
        static let whiteSignalDuration = 0.12
    }

    /// どのカメラでも黒い部品
    enum Parts {
        static let well = Color(hex: 0x0E0D0C)
        static let ring = Color(hex: 0x3A3832)
        static let digit = Color(hex: 0xF2EDE4)
    }

    enum Counter {
        static let width: CGFloat = 38
        static let height: CGFloat = 26
        static let cornerRadius: CGFloat = 6
    }

    enum Dial {
        static let width: CGFloat = 170
        static let height: CGFloat = 48
        static let cornerRadius: CGFloat = 12
        static let ringColor = Color(hex: 0x2E2C27)
        static let base = Color(hex: 0x3A3731)
        static let groove = Color(hex: 0x4E4A41)
        static let gap = Color(hex: 0x22201C)
        static let groovePeriod: CGFloat = 8
        static let grooveWidth: CGFloat = 3
        static let edgeShade: CGFloat = 26
        static let bounceDistance: CGFloat = 4
        static let bounceDuration = 0.14
    }

    enum Flash {
        static let width: CGFloat = 34
        static let height: CGFloat = 68
        static let cornerRadius: CGFloat = 7
        static let padding: CGFloat = 3
        static let knobWidth: CGFloat = 28
        static let knobHeight: CGFloat = 34
        static let knobCornerRadius: CGFloat = 5
        static let knobColor = Color(hex: 0x4A463E)
        static let bumpLight = Color(hex: 0x6E695E)
        static let bumpDark = Color(hex: 0x3A3731)
        static let bumpSpacing: CGFloat = 3
        static let lampSize: CGFloat = 8
        static let lampOn = Color(hex: 0xFF6A2B)
        static let lampOff = Color(hex: 0x3A3832)
        static let dragThreshold: CGFloat = 6
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
