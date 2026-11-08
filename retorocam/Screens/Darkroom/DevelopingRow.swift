import SwiftUI

struct DevelopingRow: View {
    let roll: Roll
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Text(verbatim: "\(roll.shots.count)").font(Theme.Darkroom.count)
                VStack(alignment: .leading, spacing: 3) {
                    Text("現像中").font(Theme.Darkroom.rowTitle)
                    remaining.font(Theme.Darkroom.rowDetail).foregroundStyle(Theme.Common.subText)
                }
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Theme.Darkroom.barTrack
                    Theme.Common.accent.frame(width: proxy.size.width * roll.deliveryProgress(at: now))
                }
                .clipShape(Capsule())
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Common.card, in: RoundedRectangle(cornerRadius: 14))
    }

    private var remaining: Text {
        switch roll.remainingTime(at: now) {
        case .hours(let hours): Text("届くまであと\(hours)時間")
        case .minutes(let minutes): Text("届くまであと\(minutes)分")
        }
    }
}
