import SwiftUI

/// 巻き上げダイヤル。右になぞった量だけを `onWind` で渡す。
struct WindDial: View {
    let spin: CGFloat
    let isBouncing: Bool
    let onWind: (CGFloat) -> Void

    @State private var lastX: CGFloat?

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Theme.Dial.gap))
            let period = Theme.Dial.groovePeriod
            var x = spin.truncatingRemainder(dividingBy: period) - period
            while x < size.width {
                let groove = CGRect(x: x, y: 0, width: Theme.Dial.grooveWidth, height: size.height)
                context.fill(Path(groove), with: .color(Theme.Dial.groove))
                x += period
            }
        }
        .overlay { edgeShade }
        .clipShape(shape)
        .overlay { shape.stroke(Theme.Dial.ringColor, lineWidth: 2) }
        .frame(width: Theme.Dial.width, height: Theme.Dial.height)
        .contentShape(shape)
        .offset(x: isBouncing ? Theme.Dial.bounceDistance : 0)
        .animation(.easeOut(duration: Theme.Dial.bounceDuration / 2), value: isBouncing)
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { value in
                    if let lastX { onWind(value.location.x - lastX) }
                    lastX = value.location.x
                }
                .onEnded { _ in lastX = nil }
        )
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Theme.Dial.cornerRadius)
    }

    private var edgeShade: some View {
        HStack(spacing: 0) {
            LinearGradient(colors: [.black.opacity(0.9), .clear], startPoint: .leading, endPoint: .trailing)
                .frame(width: Theme.Dial.edgeShade)
            Spacer(minLength: 0)
            LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .leading, endPoint: .trailing)
                .frame(width: Theme.Dial.edgeShade)
        }
        .allowsHitTesting(false)
    }
}
