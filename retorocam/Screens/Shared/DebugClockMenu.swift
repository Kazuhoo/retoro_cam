#if DEBUG
import SwiftUI

/// 3日待たずに確認するための時間メニュー
struct DebugClockMenu: View {
    let services: AppServices
    let onChange: () -> Void

    var body: some View {
        Menu {
            item("+1時間") { DebugClock.advance(by: 3600) }
            item("+24時間") { DebugClock.advance(by: 24 * 3600) }
            item("+72時間") { DebugClock.advance(by: 72 * 3600) }
            item("時間を戻す") { DebugClock.reset() }
            item("このロールを10秒後に届ける") { deliverLatestSoon() }
        } label: {
            Text(verbatim: "[TIME]").font(Theme.Text.hintBold)
        }
    }

    private func item(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            onChange()
        } label: {
            Text(verbatim: title)
        }
    }

    /// 現像中でいちばん新しいロールを対象にする
    private func deliverLatestSoon() {
        let now = services.clock.now
        let developing = services.rolls.allRolls().filter { $0.isDeveloping(at: now) }
        guard let roll = developing.max(by: { ($0.sentAt ?? .distantPast) < ($1.sentAt ?? .distantPast) }) else { return }
        roll.deliverAt = now.addingTimeInterval(10)
        services.rolls.save()
        Task {
            await services.notifier.schedule(rollID: roll.id, cameraName: roll.camera.theme.name, after: 10)
        }
    }
}
#endif
