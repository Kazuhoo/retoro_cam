import SwiftUI

/// 残り枚数の窓。巻いた量に合わせて次の数字へ回る。
struct FrameCounter: View {
    let remaining: Int
    /// 0〜1
    let progress: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            digits(remaining)
            digits(max(remaining - 1, 0))
        }
        .offset(y: Theme.Counter.height * (0.5 - progress))
        .frame(width: Theme.Counter.width, height: Theme.Counter.height)
        .background(Theme.Parts.well)
        .overlay { depthShade }
        .clipShape(shape)
        .overlay { shape.stroke(Theme.Parts.ring, lineWidth: 1.5) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("残り\(remaining)枚"))
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Theme.Counter.cornerRadius)
    }

    private func digits(_ value: Int) -> some View {
        Text(verbatim: String(format: "%02d", value))
            .font(Theme.Text.counter)
            .foregroundStyle(Theme.Parts.digit)
            .frame(height: Theme.Counter.height)
    }

    private var depthShade: some View {
        LinearGradient(stops: [.init(color: .black.opacity(0.8), location: 0),
                               .init(color: .clear, location: 0.3),
                               .init(color: .clear, location: 0.7),
                               .init(color: .black.opacity(0.8), location: 1)],
                       startPoint: .top, endPoint: .bottom)
            .allowsHitTesting(false)
    }
}
