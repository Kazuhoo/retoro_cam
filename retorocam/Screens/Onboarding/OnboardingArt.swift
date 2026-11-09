import SwiftUI

/// オンボーディング各ページの絵
struct OnboardingArt: View {
    let index: Int

    var body: some View {
        switch index {
        case 0: StepsArt()
        case 1: VolumeButtonArt()
        case 2: WindArt()
        default: EnvelopeArt()
        }
    }
}

private struct StepsArt: View {
    var body: some View {
        HStack(spacing: 14) {
            step("camera", "撮る", fill: Theme.Onboarding.iconBox, icon: Theme.Common.text)
            arrow
            step("clock", "待つ", fill: Theme.Onboarding.iconBox, icon: Theme.Common.text)
            arrow
            step("envelope", "受け取る", fill: Theme.Common.accent, icon: Theme.Common.background)
        }
    }

    private var arrow: some View {
        Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold))
            .foregroundStyle(Theme.Common.subText)
    }

    private func step(_ symbol: String, _ title: LocalizedStringKey, fill: Color, icon: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 26))
                .foregroundStyle(icon)
                .frame(width: 64, height: 64)
                .background(fill, in: RoundedRectangle(cornerRadius: 16))
            Text(title).font(.system(size: 13))
        }
    }
}

private struct VolumeButtonArt: View {
    @State private var pressing = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 10).fill(Theme.Onboarding.iconBox).padding(14)
            RoundedRectangle(cornerRadius: 22).stroke(Theme.Onboarding.phoneLine, lineWidth: 3)
            HStack(spacing: 10) {
                volumeButton
                volumeButton
            }
            .offset(x: -60, y: -7)
            .opacity(pressing ? 0.25 : 1)
            Image(systemName: "hand.point.up")
                .font(.system(size: 34))
                .rotationEffect(.degrees(180))
                .offset(x: -74, y: pressing ? -46 : -52)
        }
        .frame(width: 250, height: 126)
        .offset(y: 16)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { pressing = true }
        }
    }

    private var volumeButton: some View {
        Capsule().fill(Theme.Common.accent).frame(width: 30, height: 6)
    }
}

private struct WindArt: View {
    @State private var nudged = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Text(verbatim: "23")
                    .font(.system(size: 22, design: .monospaced))
                    .frame(width: 44, height: 32)
                    .background(Theme.Onboarding.counter, in: RoundedRectangle(cornerRadius: 7))
                    .overlay { RoundedRectangle(cornerRadius: 7).stroke(Theme.Onboarding.dotOff, lineWidth: 1.5) }
                dial
            }
            Image(systemName: "arrow.right")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.Common.accent)
                .offset(x: nudged ? 10 : 0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { nudged = true }
        }
    }

    private var dial: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Theme.Onboarding.dialDark))
            var x: CGFloat = 0
            while x < size.width {
                context.fill(Path(CGRect(x: x, y: 0, width: 3, height: size.height)), with: .color(Theme.Onboarding.dialLight))
                x += 8
            }
        }
        .overlay {
            LinearGradient(stops: [.init(color: .black.opacity(0.9), location: 0),
                                   .init(color: .clear, location: 0.12),
                                   .init(color: .clear, location: 0.88),
                                   .init(color: .black.opacity(0.9), location: 1)],
                           startPoint: .leading, endPoint: .trailing)
        }
        .frame(width: 190, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay { RoundedRectangle(cornerRadius: 14).stroke(Theme.Onboarding.dialEdge, lineWidth: 2) }
    }
}

private struct EnvelopeArt: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Theme.Onboarding.envelope
            VStack(spacing: 0) {
                Theme.Onboarding.envelopeFlap.frame(height: 42)
                Spacer(minLength: 0)
                Theme.Common.accent.frame(height: 6)
                Theme.Common.background.frame(height: 22)
            }
            Text(verbatim: "24 EXP")
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(Theme.Onboarding.labelText)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Theme.Onboarding.labelPaper)
                .padding(.trailing, 14)
                .padding(.bottom, 40)
        }
        .frame(width: 230, height: 144)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.5), radius: 11, y: 10)
    }
}
