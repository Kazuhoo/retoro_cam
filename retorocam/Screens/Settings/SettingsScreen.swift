import SwiftUI

struct SettingsScreen: View {
    let settings: AppSettings
    let onBack: () -> Void
    let onShowGuide: () -> Void
    @State private var model: SettingsModel
    @Environment(\.openURL) private var openURL
    @Environment(AdsController.self) private var ads

    init(settings: AppSettings, purchases: any PurchaseProviding,
         onBack: @escaping () -> Void, onShowGuide: @escaping () -> Void) {
        self.settings = settings
        self.onBack = onBack
        self.onShowGuide = onShowGuide
        _model = State(initialValue: SettingsModel(purchases: purchases))
    }

    var body: some View {
        @Bindable var settings = settings
        ZStack {
            Theme.Common.background.ignoresSafeArea()
            VStack(spacing: Theme.Settings.gap) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Theme.Settings.gap) {
                        Grid(horizontalSpacing: Theme.Settings.columnGap, verticalSpacing: Theme.Settings.gap) {
                            GridRow {
                                SettingsToggleRow(title: Text("日付の焼き込み"), isOn: $settings.dateStamp)
                                SettingsToggleRow(title: Text("光漏れ"), isOn: $settings.lightLeak)
                            }
                            GridRow {
                                SettingsToggleRow(title: Text("巻き上げ音・効果音"), isOn: $settings.sound)
                                SettingsToggleRow(title: Text("振動（ハプティクス）"), isOn: $settings.haptics)
                            }
                            GridRow {
                                SettingsLinkRow(title: "使い方を見る", isEnabled: true, action: onShowGuide)
                                SettingsLinkRow(title: "購入を復元", isEnabled: !model.isRestoring) {
                                    Task { await model.restore() }
                                }
                            }
                            GridRow {
                                linkRow("プライバシーポリシー", url: AppLinks.privacyPolicy)
                                linkRow("利用規約", url: AppLinks.terms)
                            }
                            if ads.isPrivacyOptionsRequired {
                                GridRow {
                                    SettingsLinkRow(title: "プライバシー設定", isEnabled: true) {
                                        Task { await ads.presentPrivacyOptions() }
                                    }
                                    Color.clear.frame(height: 0)
                                }
                            }
                        }
                        #if DEBUG
                        DebugSettingsSection()
                        #endif
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                footer
            }
            .padding(.top, Theme.Settings.topPadding)
            .padding(.horizontal, Theme.Settings.horizontalPadding)
        }
        .foregroundStyle(Theme.Common.text)
        .statusBarHidden()
    }

    private var header: some View {
        HStack {
            Text("設定").font(Theme.FilmLoad.title)
            Spacer()
            Button(action: onBack) {
                Text("カメラに戻る").font(Theme.Darkroom.button)
                    .foregroundStyle(Theme.Common.text)
                    .frame(height: Theme.Layout.iconSize)
                    .padding(.horizontal, 16)
                    .background(Theme.Common.button, in: Capsule())
            }
        }
    }

    private func linkRow(_ title: LocalizedStringKey, url: URL?) -> some View {
        SettingsLinkRow(title: title, isEnabled: url != nil) {
            if let url { openURL(url) }
        }
    }

    private var footer: some View {
        VStack(spacing: 2) {
            if let message = model.restoreMessage {
                Text(message).foregroundStyle(Theme.Common.accent)
            } else {
                Text("現像前の写真はアプリの中にあります。アプリを削除すると消えます。")
            }
            Text("バージョン \(model.version)")
        }
        .font(Theme.Settings.footer)
        .foregroundStyle(Theme.Common.subText)
    }
}

struct SettingsToggleRow: View {
    let title: Text
    @Binding var isOn: Bool

    var body: some View {
        Button { isOn.toggle() } label: {
            HStack {
                title.font(Theme.Settings.row)
                Spacer(minLength: 8)
                track
            }
            .settingsRow()
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(isOn ? Text(verbatim: "ON") : Text(verbatim: "OFF"))
    }

    private var track: some View {
        let size = Theme.Settings.trackSize
        return Capsule()
            .fill(isOn ? Theme.Settings.trackOn : Theme.Settings.trackOff)
            .frame(width: size.width, height: size.height)
            .overlay(alignment: isOn ? .trailing : .leading) {
                Circle().fill(Theme.Common.text)
                    .frame(width: Theme.Settings.knob, height: Theme.Settings.knob)
                    .padding(3)
            }
            .animation(.easeOut(duration: 0.15), value: isOn)
    }
}

private struct SettingsLinkRow: View {
    let title: LocalizedStringKey
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title).font(Theme.Settings.row)
                Spacer(minLength: 8)
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(isEnabled ? Theme.Common.text : Theme.Common.subText.opacity(0.6))
            .settingsRow()
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

extension View {
    func settingsRow() -> some View {
        padding(.horizontal, Theme.Settings.rowPadding)
            .frame(maxWidth: .infinity, minHeight: Theme.Settings.rowHeight)
            .background(Theme.Common.card, in: RoundedRectangle(cornerRadius: Theme.Settings.rowRadius))
            .contentShape(Rectangle())
    }
}
