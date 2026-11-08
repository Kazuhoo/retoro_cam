import SwiftUI

/// カメラを選ぶ（撮影の途中は「カメラを見る」）
struct FilmLoadScreen: View {
    @State private var model: FilmLoadModel
    let onBack: () -> Void
    let onOpen: (CameraID) -> Void
    let onPurchase: (PurchaseRequest) -> Void

    init(selected: CameraID, isMidRoll: Bool, purchases: any PurchaseProviding, onBack: @escaping () -> Void,
         onOpen: @escaping (CameraID) -> Void, onPurchase: @escaping (PurchaseRequest) -> Void) {
        _model = State(initialValue: FilmLoadModel(selected: selected, isMidRoll: isMidRoll, purchases: purchases))
        self.onBack = onBack
        self.onOpen = onOpen
        self.onPurchase = onPurchase
    }

    var body: some View {
        ZStack {
            Theme.Common.background.ignoresSafeArea()
            VStack(spacing: Theme.FilmLoad.gap) {
                header
                cards
                footer
                Color.clear.frame(height: Theme.Layout.adHeight)   // 広告の場所（M6）
            }
            .padding(.top, Theme.FilmLoad.topPadding)
        }
        .foregroundStyle(Theme.Common.text)
        .statusBarHidden()
        .task { await model.purchases.loadPrices() }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(model.isMidRoll ? "カメラを見る" : "カメラを選ぶ").font(Theme.FilmLoad.title)
            Text("どのカメラも24枚撮り").font(Theme.FilmLoad.note).foregroundStyle(Theme.Common.subText)
            Spacer()
            if model.isMidRoll {
                Button(action: onBack) {
                    Text("戻る").font(Theme.FilmLoad.secondary)
                        .frame(height: Theme.Layout.iconSize)
                        .padding(.horizontal, 16)
                        .background(Theme.Common.button, in: Capsule())
                }
            }
        }
    }

    private var cards: some View {
        HStack(spacing: Theme.FilmLoad.gap) {
            ForEach(CameraID.allCases, id: \.self) { camera in
                Button { model.select(camera) } label: {
                    CameraCard(camera: camera, isSelected: model.selected == camera, purchases: model.purchases)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 1) {
                if let message = model.message {
                    Text(message).foregroundStyle(Theme.Common.accent)
                } else if model.isMidRoll {
                    Text("今のカメラを撮り切ったら、次のカメラとして選べます。")
                    Text("買ったカメラは何度でも使えます。")
                } else {
                    Text("買ったカメラは何度でも使えます。")
                    Text("24枚撮り切ったら、カメラごと現像に出します。")
                }
            }
            .font(Theme.FilmLoad.note)
            .foregroundStyle(Theme.Common.subText)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            if model.showsBundle { bundleButton }
            primaryButton
        }
        .frame(height: Theme.FilmLoad.buttonHeight)
    }

    private var bundleButton: some View {
        let price = model.purchases.displayPrice(for: .bundle)
        return Button {
            Task {
                if await model.buyBundle() {
                    onPurchase(PurchaseRequest(item: .bundle, startsAtPack: true, selected: model.selected))
                }
            }
        } label: {
            Group {
                if let price {
                    Text("4台セット \(price)")
                } else if model.purchases.isLoadingPrices {
                    Text(verbatim: "…")
                } else {
                    Text("価格を取得できませんでした")
                }
            }
            .font(Theme.FilmLoad.secondary)
            .foregroundStyle(price == nil ? Theme.Common.subText : Theme.Common.text)
            .frame(height: Theme.FilmLoad.buttonHeight)
            .padding(.horizontal, 12)
        }
        .disabled(price == nil || model.isBuying)
    }

    @ViewBuilder
    private var primaryButton: some View {
        if !model.isSelectedUsable {
            Button {
                onPurchase(PurchaseRequest(item: .camera(model.selected), startsAtPack: false, selected: model.selected))
            } label: {
                capsule(Text("詳しく見る"), fill: Theme.lightButton, text: Theme.Common.background)
            }
        } else if model.isMidRoll {
            capsule(Text("撮り切ったら選べます"), fill: Theme.Common.button, text: Theme.Common.subText)
        } else {
            Button {
                // 選択の直後は表示が古いことがあるので、押した時点で確かめる
                if model.isSelectedUsable, !model.isMidRoll { onOpen(model.selected) }
            } label: {
                capsule(Text("このカメラを開ける"), fill: Theme.Common.accent, text: Theme.Common.background)
            }
        }
    }

    private func capsule(_ label: Text, fill: Color, text: Color) -> some View {
        label.font(Theme.FilmLoad.primary)
            .foregroundStyle(text)
            .frame(height: Theme.FilmLoad.buttonHeight)
            .padding(.horizontal, 22)
            .background(fill, in: Capsule())
    }
}
