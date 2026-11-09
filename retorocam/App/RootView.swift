import SwiftUI

struct RootView: View {
    let model: CameraModel
    let services: AppServices
    let router: AppRouter
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        content
            .environment(services.ads)
            // ATT は画面が前面にあるときしか出せない。オンボーディングの完了でも見直す
            .task(id: "\(scenePhase)-\(services.settings.hasSeenOnboarding)") {
                if scenePhase == .active { await services.ads.startIfNeeded() }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch router.screen {
        case .shooting:
            CameraScreen(model: model, services: services,
                         onSend: { router.screen = .sendLab },
                         onOpenDarkroom: { router.screen = .darkroom },
                         onOpenSettings: { router.screen = .settings })
        case .sendLab:
            if let roll = model.roll {
                SendLabScreen(roll: roll, services: services,
                              onLater: { router.screen = .shooting },
                              onOpenNext: { router.screen = .filmLoad(selected: .sunshine) })
            }
        case .darkroom:
            DarkroomScreen(camera: model, services: services, router: router)
        case .prints(let roll):
            PrintsScreen(roll: roll, services: services, onBack: { router.screen = .darkroom })
                .id(roll.id)
        case .filmLoad(let selected):
            FilmLoadScreen(selected: selected, isMidRoll: model.hasShootingRoll, purchases: services.purchases,
                           onBack: { router.screen = .darkroom },
                           onOpen: open,
                           onPurchase: { router.screen = .purchase($0) })
        case .purchase(let request):
            PurchaseScreen(request: request, isMidRoll: model.hasShootingRoll, purchases: services.purchases,
                           onBack: { router.screen = .filmLoad(selected: $0) },
                           onOpen: open)
        case .settings:
            SettingsScreen(settings: services.settings, purchases: services.purchases,
                           onBack: { router.screen = .shooting },
                           onShowGuide: { router.screen = .onboarding(isReplay: true) })
        case .onboarding(let isReplay):
            OnboardingScreen(isReplay: isReplay) {
                if isReplay {
                    router.screen = .settings
                } else {
                    await finishFirstOnboarding()
                }
            }
        }
    }

    /// カメラの許可を求めてから進む（拒否されても止めない）
    private func finishFirstOnboarding() async {
        await model.requestAccess()
        services.settings.hasSeenOnboarding = true
        router.screen = model.hasShootingRoll ? .shooting : .filmLoad(selected: .sunshine)
    }

    private func open(_ camera: CameraID) {
        model.openRoll(camera: camera)
        router.screen = .shooting
    }
}
