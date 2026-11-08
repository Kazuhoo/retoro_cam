import SwiftUI

enum Theme {
    /// 撮影画面以外でも使う共通の暗い配色
    enum Common {
        static let background = Color(hex: 0x1C1B19)
        static let text = Color(hex: 0xF2EDE4)
    }

    enum Viewfinder {
        static let width: CGFloat = 507
        static let height: CGFloat = 338
        static let cornerRadius: CGFloat = 14
        static let ringWidth: CGFloat = 2
        static let ringColor = Color(hex: 0x2E2C27)
        static let leadingPadding: CGFloat = 26
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
