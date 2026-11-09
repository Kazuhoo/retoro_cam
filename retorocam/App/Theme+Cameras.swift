import SwiftUI

/// カメラを選ぶ・買う画面の値
extension Theme {
    static let lightButton = Color(hex: 0xF2EDE4)

    enum FilmLoad {
        static let topPadding: CGFloat = 12
        static let gap: CGFloat = 10
        static let title = Font.system(size: 22, weight: .bold)
        static let note = Font.system(size: 12)
        static let cardRadius: CGFloat = 14
        static let cardPadding: CGFloat = 10
        static let cardSelected = Color(hex: 0x2A2520)
        static let borderSelected = Color(hex: 0xF08A24)
        static let border = Color(hex: 0x34312B)
        static let ownedBadge = Color(hex: 0x2E4A33)
        static let illustrationWidth: CGFloat = 112
        static let name = Font.system(size: 15, weight: .bold, design: .monospaced)
        static let summary = Font.system(size: 11)
        static let badge = Font.system(size: 10, weight: .bold)
        static let sampleHeight: CGFloat = 30
        static let buttonHeight: CGFloat = 44
        static let primary = Font.system(size: 15, weight: .bold)
        static let secondary = Font.system(size: 12, weight: .bold)
    }

    enum Purchase {
        static let gap: CGFloat = 12
        static let columnGap: CGFloat = 24
        static let paper = Color(hex: 0xF6F1E6)
        static let largeSample = CGSize(width: 330, height: 220)
        static let smallSample = CGSize(width: 150, height: 105)
        static let largePadding: CGFloat = 8
        static let smallPadding: CGFloat = 6
        static let illustrationWidth: CGFloat = 96
        static let name = Font.system(size: 26, weight: .bold, design: .monospaced)
        static let body = Font.system(size: 13)
        static let note = Font.system(size: 12)
        static let message = Color(hex: 0xC9C3B8)
        static let doneBody = Font.system(size: 14)
        static let doneGap: CGFloat = 48
    }

    enum Pack {
        static let size = CGSize(width: 380, height: 200)
        static let flapHeight: CGFloat = 34
        static let illustrationWidth: CGFloat = 120
        static let name = Font.system(size: 28, weight: .bold, design: .monospaced)
        static let title = Font.system(size: 15, weight: .bold)
        static let hint = Font.system(size: 12)
        static let fullTear: CGFloat = 300
        static let opening = Color(hex: 0x1C1B19)
        static let silver = Color(hex: 0xC4C8CC)
        static let silverBand = Color(hex: 0x8E949A)
        static let silverText = Color(hex: 0x1C1B19)
    }
}
