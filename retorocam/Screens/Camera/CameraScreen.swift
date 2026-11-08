import SwiftUI

/// M1 の仮画面：ファインダーだけ。本番のレイアウトは M2。
struct CameraScreen: View {
    let model: CameraModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Theme.Common.background.ignoresSafeArea()
            content
        }
        .statusBarHidden()
        .task(id: scenePhase) {
            if scenePhase == .active {
                await model.activate()
            } else if scenePhase == .background {
                await model.deactivate()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.access {
        case .unknown:
            EmptyView()
        case .denied:
            Text("カメラが使えません。設定アプリでカメラをオンにしてください")
                .foregroundStyle(Theme.Common.text)
        case .granted:
            HStack {
                viewfinder.padding(.leading, Theme.Viewfinder.leadingPadding)
                Spacer()
            }
        }
    }

    private var viewfinder: some View {
        CameraPreviewView(camera: model.camera)
            .frame(width: Theme.Viewfinder.width, height: Theme.Viewfinder.height)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Viewfinder.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Viewfinder.cornerRadius)
                    .stroke(Theme.Viewfinder.ringColor, lineWidth: Theme.Viewfinder.ringWidth)
            }
            .background {
                CaptureEventView(isEnabled: model.isSessionRunning) { model.shutter() }
            }
            .modifier(SimulatorShutterKeys(model: model))
    }
}
