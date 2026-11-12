import GoogleMobileAds
import SwiftUI
import UIKit

/// 画面の下に置く広告枠。広告を出さないセッションでは場所も取らない
struct AdSlot: View {
    @Environment(AdsController.self) private var ads

    var body: some View {
        if ads.showsSlot {
            let size = largeLandscapeAnchoredAdaptiveBanner(width: Self.safeWidth)
            // 読み込み前や失敗時も高さを空けて、画面がずれないようにする
            Color.clear
                .frame(height: size.size.height)
                .overlay {
                    if ads.isReady {
                        BannerAdView(adSize: size).frame(width: size.size.width, height: size.size.height)
                    }
                }
        }
    }

    /// セーフエリアの内側の幅（画面の余白に関係なく、端まで使う）
    private static var safeWidth: CGFloat {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first?.keyWindow else { return 320 }
        return window.bounds.inset(by: window.safeAreaInsets).width
    }
}
