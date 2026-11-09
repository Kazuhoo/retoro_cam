import SwiftUI

struct RootView: View {
    let model: CameraModel
    let services: AppServices
    let router: AppRouter

    var body: some View {
        switch router.screen {
        case .shooting:
            CameraScreen(model: model, services: services,
                         onSend: { router.screen = .sendLab },
                         onOpenDarkroom: { router.screen = .darkroom })
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
        }
    }

    private func open(_ camera: CameraID) {
        model.openRoll(camera: camera)
        router.screen = .shooting
    }
}
