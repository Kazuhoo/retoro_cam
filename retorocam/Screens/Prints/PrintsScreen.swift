import SwiftUI
import UIKit

struct PrintsScreen: View {
    @State private var model: PrintsModel
    let onBack: () -> Void

    init(roll: Roll, services: AppServices, onBack: @escaping () -> Void) {
        _model = State(initialValue: PrintsModel(roll: roll, services: services))
        self.onBack = onBack
    }

    var body: some View {
        ZStack {
            Theme.Common.background.ignoresSafeArea()
            VStack(spacing: 8) {
                header
                content.frame(maxHeight: .infinity)
                Color.clear.frame(height: Theme.Layout.adHeight)   // 広告の場所（M6）
            }
            .padding(.top, Theme.Darkroom.topPadding)
            .padding(.horizontal, Theme.Darkroom.horizontalPadding)
        }
        .foregroundStyle(Theme.Common.text)
        .statusBarHidden()
        .onAppear { model.appear() }
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Text("現像")
                    .font(Theme.Darkroom.button)
                    .foregroundStyle(Theme.Common.text)
                    .frame(height: Theme.Layout.iconSize)
                    .padding(.horizontal, 16)
                    .background(Theme.Common.button, in: Capsule())
            }
            Spacer()
            Text(verbatim: "\(model.roll.shootingPeriod()) ・ \(model.shots.count)枚")
                .font(Theme.Darkroom.button)
                .foregroundStyle(Theme.Common.subText)
            Spacer()
            Text(verbatim: model.showsPhotos ? "\(model.index + 1)/\(model.shots.count)" : "")
                .font(.system(size: 18, design: .monospaced))
                .frame(width: 70, alignment: .trailing)
        }
    }

    @ViewBuilder
    private var content: some View {
        if model.showsPhotos {
            VStack(spacing: 4) {
                PhotoStackView(model: model)
                hint
            }
        } else {
            EnvelopeOpeningView(model: model)
        }
    }

    @ViewBuilder
    private var hint: some View {
        Group {
            if model.saveResult == .failed {
                HStack(spacing: 10) {
                    Text("写真アプリに保存できませんでした")
                    Button("設定を開く") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .tint(Theme.Common.accent)
                }
            } else if model.isLast {
                Text("これで全部です")
            } else if model.saveResult == .saved && model.index == 0 {
                Text("\(model.shots.count)枚を写真アプリに保存しました ・ 左右にスワイプしてめくる")
            } else {
                Text("左右にスワイプしてめくる")
            }
        }
        .font(Theme.Text.hint)
        .foregroundStyle(Theme.Common.subText)
        .frame(height: 22)
    }
}
