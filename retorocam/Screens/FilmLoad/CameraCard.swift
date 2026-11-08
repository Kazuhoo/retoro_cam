import SwiftUI

struct CameraCard: View {
    let camera: CameraID
    let isSelected: Bool
    let purchases: any PurchaseProviding

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            badge.frame(height: 18)
            illustration
            Text(verbatim: camera.theme.name)
                .font(Theme.FilmLoad.name)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(camera.profile.summary)
                .font(Theme.FilmLoad.summary)
                .foregroundStyle(Theme.Common.subText)
                .lineLimit(2, reservesSpace: true)
            Spacer(minLength: 0)
            samples
        }
        .padding(Theme.FilmLoad.cardPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(isSelected ? Theme.FilmLoad.cardSelected : Theme.Common.card,
                    in: RoundedRectangle(cornerRadius: Theme.FilmLoad.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.FilmLoad.cardRadius)
                .stroke(isSelected ? Theme.FilmLoad.borderSelected : Theme.FilmLoad.border, lineWidth: 2)
        }
    }

    @ViewBuilder
    private var badge: some View {
        if camera.isFree {
            badgeLabel(Text("無料"), fill: Theme.Common.accent, text: Theme.Common.background)
        } else if purchases.isUsable(camera) {
            badgeLabel(Text("購入済み"), fill: Theme.FilmLoad.ownedBadge, text: Theme.Common.text)
        } else {
            HStack(spacing: 3) {
                Image(systemName: "lock.fill").font(.system(size: 9))
                if let price = purchases.displayPrice(for: .camera(camera)) {
                    Text(verbatim: price).font(Theme.FilmLoad.badge)
                }
            }
            .foregroundStyle(Theme.Common.subText)
        }
    }

    private func badgeLabel(_ label: Text, fill: Color, text: Color) -> some View {
        label.font(Theme.FilmLoad.badge)
            .foregroundStyle(text)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(fill, in: Capsule())
    }

    /// カードが狭い端末では絵を小さくする
    private var illustration: some View {
        GeometryReader { proxy in
            ScaledCameraIllustration(camera: camera, width: min(Theme.FilmLoad.illustrationWidth, proxy.size.width))
                .frame(maxWidth: .infinity)
        }
        .aspectRatio(CameraIllustration.size.width / CameraIllustration.size.height, contentMode: .fit)
        .frame(maxWidth: Theme.FilmLoad.illustrationWidth)
        .frame(maxWidth: .infinity)
    }

    private var samples: some View {
        HStack(spacing: 3) {
            ForEach(Array(camera.profile.samples.enumerated()), id: \.offset) { _, sample in
                SampleSwatch(light: sample.light, dark: sample.dark)
            }
        }
        .frame(height: Theme.FilmLoad.sampleHeight)
    }
}

/// 作例の仮の絵（M7 で実際の写真に差し替える）
struct SampleSwatch: View {
    let light: Color
    let dark: Color

    var body: some View {
        GeometryReader { proxy in
            RadialGradient(colors: [light, dark], center: UnitPoint(x: 0.4, y: 0.35),
                           startRadius: 0, endRadius: max(proxy.size.width, proxy.size.height) * 0.75)
        }
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}
