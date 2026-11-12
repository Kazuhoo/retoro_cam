import SwiftUI

/// 下端のストライプと帯
struct CameraStripes: View {
    let theme: CameraTheme

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(theme.stripes.enumerated()), id: \.offset) { _, color in
                color.frame(height: Theme.Layout.stripeHeight)
            }
            theme.band
        }
        .frame(height: Theme.Layout.stripesTotalHeight)
    }
}
