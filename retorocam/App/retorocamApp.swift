import SwiftUI

@main
struct retorocamApp: App {
    @State private var model = CameraModel.makeDefault()

    var body: some Scene {
        WindowGroup {
            CameraScreen(model: model)
        }
    }
}
