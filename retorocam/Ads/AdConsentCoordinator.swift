import AppTrackingTransparency
import Foundation
import UIKit
import UserMessagingPlatform

/// 広告の同意の流れ：UMP（必要な地域だけフォームが出る）→ ATT
struct AdConsentCoordinator {
    struct Result {
        let canRequestAds: Bool
        let isPrivacyOptionsRequired: Bool
    }

    func gather() async -> Result {
        let information = ConsentInformation.shared
        let parameters = RequestParameters()
        #if DEBUG
        // RETORO_UMP_EEA を渡すと、EEA の利用者として同意フォームを確認できる
        if ProcessInfo.processInfo.environment["RETORO_UMP_EEA"] != nil {
            information.reset()
            let debug = UserMessagingPlatform.DebugSettings()
            debug.geography = .EEA
            parameters.debugSettings = debug
        }
        #endif
        // 失敗しても止めない。読み込めるかは canRequestAds で判断する
        try? await information.requestConsentInfoUpdate(with: parameters)
        try? await ConsentForm.loadAndPresentIfRequired(from: UIApplication.shared.topViewController)

        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            _ = await ATTrackingManager.requestTrackingAuthorization()
        }
        return Result(canRequestAds: information.canRequestAds,
                      isPrivacyOptionsRequired: information.privacyOptionsRequirementStatus == .required)
    }

    func presentPrivacyOptions() async {
        try? await ConsentForm.presentPrivacyOptionsForm(from: UIApplication.shared.topViewController)
    }
}

extension UIApplication {
    /// いちばん手前の画面（広告の同意フォームやバナーの表示元）
    var topViewController: UIViewController? {
        let scene = connectedScenes.compactMap { $0 as? UIWindowScene }.first
        var controller = scene?.keyWindow?.rootViewController
        while let presented = controller?.presentedViewController { controller = presented }
        return controller
    }
}
