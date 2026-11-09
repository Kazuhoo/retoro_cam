import SwiftUI

/// 撮り切ったカメラの絵（220×122）
struct CameraIllustration: View {
    let camera: CameraID

    /// 元の大きさ
    static let size = CGSize(width: 220, height: 122)

    private var bodyColor: Color { camera.illustrationBody }
    private var bandColor: Color { camera.illustrationBand }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(LinearGradient(stops: [.init(color: Color(hex: 0x3C3C3C), location: 0),
                                             .init(color: Color(hex: 0x1E1E1E), location: 0.16),
                                             .init(color: Color(hex: 0x131313), location: 0.78),
                                             .init(color: Color(hex: 0x0A0A0A), location: 1)],
                                     startPoint: .top, endPoint: .bottom))
                .shadow(color: .black.opacity(0.45), radius: 7, y: 6)
            grip
            label
            lens
            viewfinderWindow
            flashWindow
            counter
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .accessibilityHidden(true)
    }

    private var grip: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(hex: 0x0B0B0B)))
            var x: CGFloat = 0
            while x < size.width {
                context.fill(Path(CGRect(x: x, y: 0, width: 2, height: size.height)), with: .color(Color(hex: 0x242424)))
                x += 4
            }
        }
        .frame(width: 26, height: 98)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .offset(x: 6, y: 12)
    }

    private var label: some View {
        ZStack(alignment: .bottom) {
            bodyColor
            LinearGradient(stops: [.init(color: .white.opacity(0.28), location: 0),
                                   .init(color: .white.opacity(0.06), location: 0.26),
                                   .init(color: .clear, location: 0.6),
                                   .init(color: .black.opacity(0.2), location: 1)],
                           startPoint: .top, endPoint: .bottom)
            VStack(spacing: 0) {
                ForEach(Array(camera.theme.stripes.enumerated()), id: \.offset) { _, color in
                    color.frame(height: 4)
                }
                bandColor
            }
            .frame(height: 24)
        }
        .frame(width: 128, height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .offset(x: 38, y: 6)
    }

    private var lens: some View {
        ZStack {
            Circle().fill(RadialGradient(stops: [.init(color: Color(hex: 0x262626), location: 0.52),
                                                 .init(color: Color(hex: 0x060606), location: 0.54),
                                                 .init(color: Color(hex: 0x060606), location: 0.62),
                                                 .init(color: Color(hex: 0x2C2C2C), location: 0.64),
                                                 .init(color: Color(hex: 0x151515), location: 1)],
                                       center: .center, startRadius: 0, endRadius: 33))
                .frame(width: 66, height: 66)
                .shadow(color: .black.opacity(0.6), radius: 4, y: 4)
            Circle().fill(RadialGradient(stops: [.init(color: Color(hex: 0x6D8199), location: 0),
                                                 .init(color: Color(hex: 0x26313E), location: 0.32),
                                                 .init(color: Color(hex: 0x070A0E), location: 0.7),
                                                 .init(color: .black, location: 1)],
                                       center: UnitPoint(x: 0.36, y: 0.3), startRadius: 0, endRadius: 22))
                .frame(width: 32, height: 32)
            Ellipse().fill(.white.opacity(0.75))
                .frame(width: 9, height: 6)
                .blur(radius: 1)
                .rotationEffect(.degrees(-30))
                .offset(x: -7.5, y: -8)
        }
        .offset(x: 70, y: 16)
    }

    private var viewfinderWindow: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(LinearGradient(colors: [Color(hex: 0x3A4856), Color(hex: 0x10161C), Color(hex: 0x05080B)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay { RoundedRectangle(cornerRadius: 3).stroke(Color(hex: 0x0A0A0A), lineWidth: 2) }
            .frame(width: 24, height: 17)
            .offset(x: 132, y: 12)
    }

    private var flashWindow: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(LinearGradient(colors: [Color(hex: 0xF6F6F2), Color(hex: 0xCFCFC6)], startPoint: .top, endPoint: .bottom))
            .overlay { RoundedRectangle(cornerRadius: 3).stroke(Color(hex: 0x1E1E1E), lineWidth: 2) }
            .frame(width: 36, height: 26)
            .offset(x: 174, y: 12)
    }

    private var counter: some View {
        Text(verbatim: "00")
            .font(Theme.dotFont(size: 17))
            .foregroundStyle(Theme.Common.text)
            .frame(width: 30, height: 18)
            .background(Color(hex: 0x050505), in: RoundedRectangle(cornerRadius: 3))
            .offset(x: 178, y: 46)
    }
}

/// カメラの絵を指定の幅に縮小したもの
struct ScaledCameraIllustration: View {
    let camera: CameraID
    let width: CGFloat

    var body: some View {
        let scale = width / CameraIllustration.size.width
        CameraIllustration(camera: camera)
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: width, height: CameraIllustration.size.height * scale, alignment: .topLeading)
    }
}
