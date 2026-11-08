import SwiftData
import SwiftUI

@main
struct retorocamApp: App {
    private let container: ModelContainer
    private let services: AppServices
    @State private var model: CameraModel
    @State private var router = AppRouter()

    init() {
        do {
            let container = try ModelContainer(for: Roll.self, Shot.self)
            let services = AppServices.makeDefault(context: container.mainContext)
            self.container = container
            self.services = services
            _model = State(initialValue: CameraModel.makeDefault(services: services))
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
