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
            self.container = container
            self.services = services
            let model = CameraModel.makeDefault(services: services)
            _model = State(initialValue: model)
            _router = State(initialValue: AppRouter(screen: model.hasShootingRoll ? .shooting : .filmLoad(selected: .sunshine)))
        } catch {
            fatalError("データベースを開けません: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: model, services: services, router: router)
                .modelContainer(container)
        }
    }
}
