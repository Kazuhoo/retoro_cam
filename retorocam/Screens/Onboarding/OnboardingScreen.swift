import SwiftUI

struct OnboardingScreen: View {
    let isReplay: Bool
    let onFinish: () async -> Void
    @State private var model = OnboardingModel()

    var body: some View {
        ZStack {
            Theme.Common.background.ignoresSafeArea()
            VStack(spacing: 10) {
                topBar
                HStack(spacing: Theme.Onboarding.gap) {
                    OnboardingArt(index: model.index)
                        .frame(width: Theme.Onboarding.panel.width, height: Theme.Onboarding.panel.height)
                        .background(Theme.Common.card, in: RoundedRectangle(cornerRadius: Theme.Onboarding.panelRadius))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Onboarding.panelRadius))
                    texts.frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: .infinity)
                bottomBar
            }
            .padding(.top, Theme.Onboarding.topPadding)
            .padding(.horizontal, Theme.Onboarding.horizontalPadding)
        }
        .foregroundStyle(Theme.Common.text)
        .statusBarHidden()
    }

    private var topBar: some View {
        HStack {
            HStack(spacing: 8) {
                ForEach(OnboardingModel.pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == model.index ? Theme.Common.accent : Theme.Onboarding.dotOff)
                        .frame(width: index == model.index ? Theme.Onboarding.dotWidthOn : Theme.Onboarding.dotWidth, height: 8)
                }
            }
            Spacer()
            if !model.isLast {
                Button { model.skip() } label: {
                    Text("スキップ").font(Theme.Darkroom.button)
                        .foregroundStyle(Theme.Common.subText)
                        .frame(height: Theme.Layout.iconSize)
                        .padding(.horizontal, 14)
                }
            }
        }
        .frame(minHeight: Theme.Layout.iconSize)
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.page.label).font(Theme.Onboarding.label).foregroundStyle(Theme.Common.accent)
            Text(model.page.title).font(Theme.Onboarding.title).lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
            Text(model.page.body).font(Theme.Onboarding.body)
                .foregroundStyle(Theme.Onboarding.bodyColor)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var bottomBar: some View {
        HStack {
            if !model.isFirst {
                Button { model.back() } label: {
                    Text("戻る").font(Theme.Darkroom.button)
                        .foregroundStyle(Theme.Common.text)
                        .frame(height: Theme.Layout.iconSize)
                        .padding(.horizontal, 16)
                        .background(Theme.Common.button, in: Capsule())
                }
            }
            Spacer()
            if model.isLast {
                Button {
                    Task { await model.finish(onFinish) }
                } label: {
                    actionLabel(isReplay ? Text("閉じる") : Text("最初のカメラを開ける"), fill: Theme.Common.accent)
                }
                .disabled(model.isFinishing)
            } else {
                Button { model.next() } label: {
                    actionLabel(Text("次へ"), fill: Theme.lightButton)
                }
            }
        }
        .frame(minHeight: Theme.Onboarding.nextHeight)
    }

    private func actionLabel(_ label: Text, fill: Color) -> some View {
        label.font(Theme.FilmLoad.primary)
            .foregroundStyle(Theme.Common.background)
            .frame(height: Theme.Onboarding.nextHeight)
            .padding(.horizontal, 30)
            .background(fill, in: Capsule())
    }
}
