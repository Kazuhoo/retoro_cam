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
            SendLabScreen(roll: model.roll, services: services,
                          onLater: { router.screen = .shooting },
                          onOpenNext: {
                              model.openNextRoll()
                              router.screen = .shooting
                          })
        case .darkroom:
            DarkroomScreen(camera: model, services: services, router: router)
        case .prints(let roll):
            PrintsScreen(roll: roll, services: services, onBack: { router.screen = .darkroom })
                .id(roll.id)
        }
    }
}
