import SwiftData
import SwiftUI

@main
struct retorocamApp: App {
    private let container: ModelContainer
    private let services: AppServices
    @State private var model: CameraModel
    @State private var router: AppRouter

    init() {
        do {
            let container = try ModelContainer(for: Roll.self, Shot.self)
            let services = AppServices.makeDefault(context: container.mainContext)
            services.settings.recordLaunch()
            SoundPlayer.prepare()
            self.container = container
            self.services = services
            let model = CameraModel.makeDefault(services: services)
            _model = State(initialValue: model)
            _router = State(initialValue: AppRouter(screen: Self.firstScreen(model: model, settings: services.settings)))
        } catch {
            fatalError("データベースを開けません: \(error)")
        }
    }

    private static func firstScreen(model: CameraModel, settings: AppSettings) -> AppRouter.Screen {
        guard settings.hasSeenOnboarding else { return .onboarding(isReplay: false) }
        return model.hasShootingRoll ? .shooting : .filmLoad(selected: .sunshine)
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: model, services: services, router: router)
                .modelContainer(container)
        }
    }
}
