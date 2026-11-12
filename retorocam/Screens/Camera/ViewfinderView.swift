import SwiftUI

/// フィルムの色をかけない素の映像に、四隅の印・周辺の暗さ・ガラスの反射を重ねる。
struct ViewfinderView: View {
    let camera: any CameraControlling
    let signal: CameraModel.Signal?

    var body: some View {
        CameraPreviewView(camera: camera)
            .overlay { vignette }
            .overlay { glass }
            .overlay { cornerMarks }
            .overlay { signalLayer }
            .clipShape(shape)
            .overlay { shape.stroke(Theme.Viewfinder.ringColor, lineWidth: Theme.Viewfinder.ringWidth) }
            .allowsHitTesting(false)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Theme.Viewfinder.cornerRadius)
    }

    private var vignette: some View {
        EllipticalGradient(stops: [.init(color: .clear, location: 0.5),
                                   .init(color: .black.opacity(0.5), location: 0.85),
                                   .init(color: .black.opacity(0.85), location: 1)],
                           center: .center, startRadiusFraction: 0, endRadiusFraction: 0.75)
    }

    private var glass: some View {
        LinearGradient(stops: [.init(color: .clear, location: 0.30),
                               .init(color: .white.opacity(0.08), location: 0.38),
                               .init(color: .clear, location: 0.46),
                               .init(color: .clear, location: 0.70),
                               .init(color: .white.opacity(0.04), location: 0.76),
                               .init(color: .clear, location: 0.82)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var cornerMarks: some View {
        CornerMarks()
            .stroke(Theme.Viewfinder.markColor.opacity(0.6), lineWidth: 2)
    }

    @ViewBuilder
    private var signalLayer: some View {
        switch signal {
        case .dark: Color.black
        case .white: Color.white
        case nil: EmptyView()
        }
    }
}

private struct CornerMarks: Shape {
    func path(in rect: CGRect) -> Path {
        let size = Theme.Viewfinder.markSize
        let frame = rect.insetBy(dx: Theme.Viewfinder.markInsetX, dy: Theme.Viewfinder.markInsetY)
        var path = Path()
        for (corner, dx, dy): (CGPoint, CGFloat, CGFloat) in [
            (CGPoint(x: frame.minX, y: frame.minY), 1, 1),
            (CGPoint(x: frame.maxX, y: frame.minY), -1, 1),
            (CGPoint(x: frame.minX, y: frame.maxY), 1, -1),
            (CGPoint(x: frame.maxX, y: frame.maxY), -1, -1),
        ] {
            path.move(to: CGPoint(x: corner.x + dx * size, y: corner.y))
            path.addLine(to: corner)
            path.addLine(to: CGPoint(x: corner.x, y: corner.y + dy * size))
        }
        return path
    }
}
