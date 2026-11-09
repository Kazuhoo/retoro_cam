import SwiftUI

struct CameraScreen: View {
    let model: CameraModel
    let services: AppServices
    let onSend: () -> Void
    let onOpenDarkroom: () -> Void
    let onOpenSettings: () -> Void
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    var body: some View {
        content
            .statusBarHidden()
            .task(id: scenePhase) {
                if scenePhase == .active {
                    await model.activate()
                } else if scenePhase == .background {
                    await model.deactivate()
                }
            }
            .task {
                while !Task.isCancelled {
                    model.refreshDeliveries()
                    try? await Task.sleep(for: .seconds(DeliveryRefresh.interval))
                }
            }
            .onDisappear {
                Task { await model.deactivate() }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch model.access {
        case .unknown:
            Theme.Common.background.ignoresSafeArea()
        case .denied:
            denied
        case .granted:
            shooting
        }
    }

    private var denied: some View {
        ZStack {
            Theme.Common.background.ignoresSafeArea()
            VStack(spacing: 18) {
                Text("カメラが使えません。設定アプリでカメラをオンにしてください")
                    .foregroundStyle(Theme.Common.text)
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                } label: {
                    Text("設定を開く")
                        .font(Theme.Text.develop)
                        .foregroundStyle(Theme.Common.background)
                        .frame(height: Theme.Status.developHeight)
                        .padding(.horizontal, Theme.Status.developPadding)
                        .background(Theme.Common.accent, in: Capsule())
                }
            }
        }
    }

    private var shooting: some View {
        let theme = model.cameraID.theme
        return GeometryReader { proxy in
            let layout = ScreenLayout(size: proxy.size, insets: proxy.safeAreaInsets)
            ZStack(alignment: .topLeading) {
                HStack(alignment: .top, spacing: Theme.Layout.columnGap) {
                    viewfinder.frame(width: layout.viewfinder.width, height: layout.viewfinder.height)
                    ShootingControls(model: model, theme: theme, onSend: onSend,
                                     onOpenDarkroom: onOpenDarkroom, onOpenSettings: onOpenSettings)
                        .frame(width: Theme.Layout.columnWidth, height: layout.viewfinder.height)
                }
                .padding(.top, Theme.Layout.topPadding)
                .padding(.horizontal, layout.horizontalPadding)

                header(theme: theme, layout: layout)
            }
        }
        .foregroundStyle(theme.text)
        .background {
            theme.body
                .overlay(alignment: .bottom) { CameraStripes(theme: theme) }
                .ignoresSafeArea()
        }
        .modifier(CameraKeyboardControls(model: model))
    }

    private var viewfinder: some View {
        ViewfinderView(camera: model.camera, signal: model.signal)
            .background {
                CaptureEventView(isEnabled: model.isSessionRunning) { model.shutter() }
            }
    }

    private func header(theme: CameraTheme, layout: ScreenLayout) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(verbatim: theme.name).font(Theme.Text.name)
            Text(verbatim: "・ 24EXP").font(Theme.Text.exposure)
            #if DEBUG
            if !DebugSettings.shared.hidesDebugButtons {
                DebugRollMenu(model: model)
                DebugClockMenu(services: services) { model.refreshDeliveries() }
            }
            #endif
            Spacer(minLength: 0)
            Image(systemName: "triangle.fill").font(.system(size: 9))
            Text("シャッター　音量ボタンを押す").font(Theme.Text.hintBold)
                .padding(.trailing, layout.shutterHintTrailing)
        }
        .foregroundStyle(theme.sub)
        .padding(.top, Theme.Layout.nameTop)
        .padding(.leading, layout.horizontalPadding + Theme.Layout.nameLeading)
    }
}

/// セーフエリアに合わせて 3:2 のファインダーの大きさを決める
private struct ScreenLayout {
    let viewfinder: CGSize
    let horizontalPadding: CGFloat
    let shutterHintTrailing: CGFloat

    init(size: CGSize, insets: EdgeInsets) {
        let edge = max(insets.leading, insets.trailing)
        horizontalPadding = max(0, Theme.Layout.horizontalPadding - edge)
        shutterHintTrailing = max(0, Theme.Layout.shutterHintTrailing - insets.trailing)

        let bottom = max(Theme.Layout.minBottomPadding, Theme.Layout.bottomPadding - insets.bottom)
        let height = min(Theme.Viewfinder.maxHeight, size.height - Theme.Layout.topPadding - bottom)
        let room = size.width - horizontalPadding * 2 - Theme.Layout.columnGap - Theme.Layout.columnWidth
        let width = min(Theme.Viewfinder.maxWidth, room, height * 3 / 2)
        viewfinder = CGSize(width: width, height: width * 2 / 3)
    }
}

#if DEBUG
private struct DebugRollMenu: View {
    let model: CameraModel

    var body: some View {
        Menu {
            Button { model.debugReset(remaining: ShootingState.totalFrames) } label: {
                Text(verbatim: "残り24に戻す")
            }
            Button { model.debugReset(remaining: 2) } label: {
                Text(verbatim: "残り2にする")
            }
        } label: {
            Text(verbatim: "[ROLL]").font(Theme.Text.hintBold)
        }
    }
}
#endif
