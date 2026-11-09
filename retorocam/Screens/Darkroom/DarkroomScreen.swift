import SwiftUI

struct DarkroomScreen: View {
    let camera: CameraModel
    let services: AppServices
    let router: AppRouter
    @State private var model: DarkroomModel

    init(camera: CameraModel, services: AppServices, router: AppRouter) {
        self.camera = camera
        self.services = services
        self.router = router
        _model = State(initialValue: DarkroomModel(services: services))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Common.background.ignoresSafeArea()
            VStack(spacing: Theme.Darkroom.gap) {
                header
                HStack(alignment: .top, spacing: Theme.Darkroom.columnGap) {
                    leftColumn.frame(width: Theme.Darkroom.leftWidth)
                    arrivedCard
                }
                .frame(maxHeight: .infinity)
                Color.clear.frame(height: Theme.Layout.adHeight)   // 広告の場所（M6）
            }
            .padding(.top, Theme.Darkroom.topPadding)
            .padding(.horizontal, Theme.Darkroom.horizontalPadding)
        }
        .foregroundStyle(Theme.Common.text)
        .statusBarHidden()
        .task {
            while !Task.isCancelled {
                model.refresh()
                try? await Task.sleep(for: .seconds(DeliveryRefresh.interval))
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("現像").font(Theme.SendLab.title)
            #if DEBUG
            DebugClockMenu(services: services) { model.refresh() }
            #endif
            Spacer()
            headerButton("カメラを見る") { router.screen = .filmLoad(selected: camera.cameraID) }
            headerButton("カメラに戻る") { router.screen = .shooting }
        }
    }

    private func headerButton(_ title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Darkroom.button)
                .foregroundStyle(Theme.Common.text)
                .frame(height: Theme.Layout.iconSize)
                .padding(.horizontal, 16)
                .background(Theme.Common.button, in: Capsule())
        }
    }

    private var leftColumn: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                currentCard
                ForEach(model.developing) { DevelopingRow(roll: $0, now: model.now) }
            }
        }
    }

    private var currentCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 16) {
                Text(verbatim: "\(camera.exposed)/\(ShootingState.totalFrames)").font(Theme.Darkroom.count)
                VStack(alignment: .leading, spacing: 3) {
                    Text("使用中のカメラ").font(Theme.Darkroom.rowTitle)
                    Group {
                        if camera.isEmpty {
                            Text("24枚、撮り切りました")
                        } else {
                            Text("あと\(ShootingState.totalFrames - camera.exposed)枚撮り切ると、現像に出せます")
                        }
                    }
                    .font(Theme.Darkroom.rowDetail)
                    .foregroundStyle(Theme.Common.subText)
                }
            }
            Button { router.screen = .sendLab } label: {
                Text("カメラごと現像に出す")
                    .font(Theme.Darkroom.button)
                    .foregroundStyle(camera.canSend ? Theme.Common.background : Theme.Common.subText)
                    .frame(height: Theme.Layout.iconSize)
                    .padding(.horizontal, 20)
                    .background {
                        if camera.canSend {
                            Capsule().fill(Theme.Common.accent)
                        } else {
                            Capsule().stroke(Theme.Common.button, lineWidth: 1)
                        }
                    }
            }
            .disabled(!camera.canSend)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Common.card, in: RoundedRectangle(cornerRadius: 14))
    }

    private var arrivedCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("届いた封筒").font(Theme.Darkroom.rowTitle)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(model.arrived) { roll in
                        Button { router.screen = .prints(roll) } label: {
                            EnvelopeRow(roll: roll)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.Common.card, in: RoundedRectangle(cornerRadius: 14))
    }
}
