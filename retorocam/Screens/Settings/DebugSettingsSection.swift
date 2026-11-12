#if DEBUG
import SwiftUI

/// 設定画面のデバッグ欄（DEBUG ビルドのみ）
struct DebugSettingsSection: View {
    @Bindable private var debug = DebugSettings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Settings.gap) {
            Text(verbatim: "デバッグ").font(Theme.Settings.footer).foregroundStyle(Theme.Common.subText)
            Grid(horizontalSpacing: Theme.Settings.columnGap, verticalSpacing: Theme.Settings.gap) {
                GridRow {
                    purchaseStateMenu
                    SettingsToggleRow(title: Text(verbatim: "すぐ現像（10秒）"), isOn: $debug.instantDevelop)
                }
                GridRow {
                    SettingsToggleRow(title: Text(verbatim: "デバッグ用ボタンを隠す"), isOn: $debug.hidesDebugButtons)
                    Color.clear.frame(height: 0)
                }
            }
        }
    }

    private var purchaseStateMenu: some View {
        Menu {
            ForEach(DebugSettings.PurchaseState.allCases, id: \.self) { state in
                Button { debug.purchaseState = state } label: { Text(verbatim: state.title) }
            }
        } label: {
            HStack {
                Text(verbatim: "有料の状態").font(Theme.Settings.row)
                Spacer(minLength: 8)
                Text(verbatim: debug.purchaseState.title).font(Theme.Settings.footer).foregroundStyle(Theme.Common.subText)
            }
            .foregroundStyle(Theme.Common.text)
            .settingsRow()
        }
    }
}
#endif
