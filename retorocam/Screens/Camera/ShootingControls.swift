import SwiftUI

/// 撮影画面の右の列
struct ShootingControls: View {
    let model: CameraModel
    let theme: CameraTheme

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            windSection
            Spacer(minLength: 4)
            status
            Spacer(minLength: 4)
            bottomRow
        }
        .padding(.top, Theme.Layout.columnTopPadding)
    }

    private var windSection: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 10) {
                FrameCounter(remaining: model.remaining, progress: model.state.windProgress)
                WindDial(spin: model.state.spin, isBouncing: model.isBouncing) { model.wind(by: $0) }
            }
            HStack(alignment: .top, spacing: 8) {
                Text("巻き上げ").font(Theme.Text.hintBold)
                Text("撮ったら、ダイヤルを右へなぞる").font(Theme.Text.hint)
            }
            .foregroundStyle(theme.sub)
        }
    }

    @ViewBuilder
    private var status: some View {
        if model.isEmpty {
            // 行き先は M3
            Button {} label: {
                Text("現像")
                    .font(Theme.Text.develop)
                    .foregroundStyle(theme.onAccent)
                    .frame(height: Theme.Status.developHeight)
                    .padding(.horizontal, Theme.Status.developPadding)
                    .background(theme.accent, in: Capsule())
            }
        } else if model.state.isWound {
            statusLine(color: Theme.Status.readyDot, glows: true, text: "撮影できます")
        } else {
            statusLine(color: theme.dot, glows: false, text: "ダイヤルを右になぞって巻き上げ")
        }
    }

    private func statusLine(color: Color, glows: Bool, text: LocalizedStringKey) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: Theme.Status.dotSize, height: Theme.Status.dotSize)
                .shadow(color: glows ? color : .clear, radius: 4)
            Text(text).font(Theme.Text.status).foregroundStyle(theme.text)
        }
    }

    private var bottomRow: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("フラッシュ").font(Theme.Text.smallBold)
                    Text("上げるとON").font(Theme.Text.small)
                    Text("1枚ごとに上げ直す").font(Theme.Text.small)
                }
                .foregroundStyle(theme.sub)
                FlashSwitch(isOn: model.isFlashOn, iconColor: theme.sub) { model.setFlash($0) }
            }
            // 行き先は M3 と M5
            iconButton("photo")
            iconButton("gearshape")
        }
    }

    private func iconButton(_ symbol: String) -> some View {
        Button {} label: {
            Image(systemName: symbol)
                .foregroundStyle(Theme.Common.text)
                .frame(width: Theme.Layout.iconSize, height: Theme.Layout.iconSize)
                .background(theme.button, in: Circle())
        }
    }
}
