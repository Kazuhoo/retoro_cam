import SwiftUI

/// アルミの袋の中身の違い
struct PackStyle {
    let name: Text
    let subtitle: Text
    let body: Color
    let band: Color
    let stripes: [Color]
    let text: Color
    let item: StoreItem

    init(item: StoreItem) {
        self.item = item
        switch item {
        case .camera(let camera):
            name = Text(verbatim: camera.theme.name)
            subtitle = Text("使い捨てカメラ ・ 24EXP")
            body = camera.illustrationBody
            band = camera.illustrationBand
            stripes = camera.theme.stripes
            text = camera.profile.packText
        case .bundle:
            name = Text("4台セット")
            subtitle = Text("使い捨てカメラ ・ 4台")
            body = Theme.Pack.silver
            band = Theme.Pack.silverBand
            stripes = CameraID.paid.map(\.theme.accent)
            text = Theme.Pack.silverText
        }
    }
}

/// 上のギザギザを右へなぞって破る袋
struct FoilPackView: View {
    let style: PackStyle
    let tear: CGFloat
    let onTear: (CGFloat) -> Void

    @State private var lastX: CGFloat?

    var body: some View {
        let size = Theme.Pack.size
        let progress = tear / Theme.Pack.fullTear
        ZStack(alignment: .topLeading) {
            packBody
                .frame(width: size.width, height: size.height - Theme.Pack.flapHeight)
                .offset(y: Theme.Pack.flapHeight)
            flap(progress: progress)
            Theme.Pack.opening
                .frame(width: progress * size.width, height: 8)
                .offset(y: 30)
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if let lastX { onTear(value.location.x - lastX) }
                    lastX = value.location.x
                }
                .onEnded { _ in lastX = nil }
        )
    }

    private var packBody: some View {
        ZStack(alignment: .topLeading) {
            style.body
            sheen
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                ForEach(Array(style.stripes.enumerated()), id: \.offset) { _, color in
                    color.frame(height: 4)
                }
                style.band.frame(minHeight: 4, maxHeight: 26 - CGFloat(style.stripes.count) * 4)
                Serration(vertical: true).background(style.body).brightness(-0.1).frame(height: 14)
            }
            .opacity(0.92)
            HStack {
                Serration(vertical: false).frame(width: 10)
                Spacer()
                Serration(vertical: false).frame(width: 10)
            }
            .opacity(0.8)
            style.name
                .font(Theme.Pack.name)
                .foregroundStyle(style.text)
                .shadow(color: .black.opacity(0.25), radius: 0, y: 1)
                .offset(x: 26, y: 20)
            style.subtitle
                .font(Theme.Pack.hint)
                .foregroundStyle(style.text.opacity(0.9))
                .offset(x: 28, y: 64)
            illustration
                .frame(width: Theme.Pack.size.width - 22, alignment: .trailing)
                .offset(y: 54)
        }
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .shadow(color: .black.opacity(0.6), radius: 13, y: 12)
    }

    @ViewBuilder
    private var illustration: some View {
        switch style.item {
        case .camera(let camera):
            ScaledCameraIllustration(camera: camera, width: Theme.Pack.illustrationWidth)
        case .bundle:
            ZStack(alignment: .leading) {
                ForEach(Array(CameraID.paid.enumerated()), id: \.offset) { index, camera in
                    ScaledCameraIllustration(camera: camera, width: 66)
                        .offset(x: CGFloat(index) * 20)
                }
            }
            .frame(width: Theme.Pack.illustrationWidth + 6, alignment: .leading)
        }
    }

    private var sheen: some View {
        ZStack {
            LinearGradient(stops: [.init(color: .clear, location: 0.12),
                                   .init(color: .white.opacity(0.32), location: 0.2),
                                   .init(color: .white.opacity(0.05), location: 0.27),
                                   .init(color: .clear, location: 0.48),
                                   .init(color: .white.opacity(0.22), location: 0.58),
                                   .init(color: .clear, location: 0.66),
                                   .init(color: .black.opacity(0.12), location: 0.85),
                                   .init(color: .white.opacity(0.15), location: 0.95)],
                           startPoint: UnitPoint(x: 0, y: 0.15), endPoint: UnitPoint(x: 1, y: 0.85))
            LinearGradient(stops: [.init(color: .white.opacity(0.18), location: 0),
                                   .init(color: .clear, location: 0.4),
                                   .init(color: .black.opacity(0.22), location: 1)],
                           startPoint: .top, endPoint: .bottom)
        }
    }

    private func flap(progress: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            style.body
            LinearGradient(colors: [.white.opacity(0.25), .black.opacity(0.1)], startPoint: .top, endPoint: .bottom)
            Serration(vertical: true)
            Line().stroke(.black.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: [4, 3])).frame(height: 2)
        }
        .frame(width: Theme.Pack.size.width, height: Theme.Pack.flapHeight)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 6, topTrailingRadius: 6))
        .brightness(-0.08)
        .rotationEffect(.degrees(-progress * 14), anchor: .bottomTrailing)
        .offset(x: tear * 0.15)
        .frame(width: Theme.Pack.size.width, height: Theme.Pack.flapHeight, alignment: .topLeading)
        .clipped()
    }
}

/// 袋の端のギザギザ
private struct Serration: View {
    /// true なら縦の筋が横に並ぶ
    let vertical: Bool

    var body: some View {
        Canvas { context, size in
            let length = vertical ? size.width : size.height
            var position: CGFloat = 0
            while position < length {
                let dark = vertical ? CGRect(x: position, y: 0, width: 1, height: size.height)
                                    : CGRect(x: 0, y: position, width: size.width, height: 1)
                let light = vertical ? CGRect(x: position + 1, y: 0, width: 2, height: size.height)
                                     : CGRect(x: 0, y: position + 1, width: size.width, height: 2)
                context.fill(Path(dark), with: .color(.black.opacity(0.26)))
                context.fill(Path(light), with: .color(.white.opacity(0.13)))
                position += 3
            }
        }
    }
}

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        Path { $0.move(to: CGPoint(x: 0, y: rect.midY)); $0.addLine(to: CGPoint(x: rect.maxX, y: rect.midY)) }
    }
}
