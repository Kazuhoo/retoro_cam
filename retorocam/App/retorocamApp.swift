import SwiftData
import SwiftUI

@main
struct retorocamApp: App {
    private let container: ModelContainer
    @State private var model: CameraModel

    init() {
        do {
            let container = try ModelContainer(for: Roll.self, Shot.self)
            self.container = container
            _model = State(initialValue: CameraModel.makeDefault(rolls: RollStore(context: container.mainContext)))
        } catch {
            fatalError("データベースを開けません: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            CameraScreen(model: model)
                .modelContainer(container)
        }
    }
}
