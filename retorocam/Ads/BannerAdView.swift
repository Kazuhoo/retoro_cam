import GoogleMobileAds
import SwiftUI
import UIKit

/// SDK のバナーを SwiftUI に載せる
struct BannerAdView: UIViewRepresentable {
    let adSize: AdSize

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = AdsController.bannerUnitID
        banner.rootViewController = UIApplication.shared.topViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
