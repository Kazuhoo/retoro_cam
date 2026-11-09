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

    enum Settings {
        static let topPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let gap: CGFloat = 10
        static let columnGap: CGFloat = 20
        static let rowHeight: CGFloat = 50
        static let rowRadius: CGFloat = 14
        static let rowPadding: CGFloat = 18
        static let row = Font.system(size: 14)
        static let footer = Font.system(size: 12)
        static let trackOn = Color(hex: 0xF08A24)
        static let trackOff = Color(hex: 0x4A473F)
        static let trackSize = CGSize(width: 46, height: 28)
        static let knob: CGFloat = 22
    }

    enum Onboarding {
        static let topPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let gap: CGFloat = 48
        static let panel = CGSize(width: 340, height: 230)
        static let panelRadius: CGFloat = 18
        static let iconBox = Color(hex: 0x2E2C27)
        static let label = Font.system(size: 12, weight: .bold)
        static let title = Font.system(size: 24, weight: .bold)
        static let body = Font.system(size: 14)
        static let bodyColor = Color(hex: 0xC9C3B8)
        static let dotOff = Color(hex: 0x3A3832)
        static let dotWidth: CGFloat = 8
        static let dotWidthOn: CGFloat = 22
        static let phoneLine = Color(hex: 0x8A847A)
        static let dialLight = Color(hex: 0x4E4A41)
        static let dialDark = Color(hex: 0x22201C)
        static let dialEdge = Color(hex: 0x2E2C27)
        static let counter = Color(hex: 0x0E0D0C)
        static let envelope = Color(hex: 0x3A3833)
        static let envelopeFlap = Color(hex: 0x2E2C28)
        static let labelPaper = Color(hex: 0xF4EEE2)
        static let labelText = Color(hex: 0x3B3328)
        static let nextHeight: CGFloat = 48
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
