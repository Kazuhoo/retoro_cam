import SwiftUI

/// カメラを買う：作例 → 袋を破る → 完了
struct PurchaseScreen: View {
    @State private var model: PurchaseModel
    let onBack: (CameraID) -> Void
    let onOpen: (CameraID) -> Void

    init(request: PurchaseRequest, isMidRoll: Bool, purchases: any PurchaseProviding,
         onBack: @escaping (CameraID) -> Void, onOpen: @escaping (CameraID) -> Void) {
        _model = State(initialValue: PurchaseModel(request: request, isMidRoll: isMidRoll, purchases: purchases))
        self.onBack = onBack
        self.onOpen = onOpen
    }

    var body: some View {
        ZStack {
            Theme.Common.background.ignoresSafeArea()
            switch model.stage {
            case .detail: detail
            case .pack: pack
            case .done:
                PurchaseDoneView(item: model.request.item, isMidRoll: model.isMidRoll) {
                    if model.isMidRoll {
                        onBack(model.returnSelection)
                    } else {
                        onOpen(model.cameraToOpen)
                    }
                }
            }
        }
        .foregroundStyle(Theme.Common.text)
        .statusBarHidden()
        .task { await model.purchases.loadPrices() }
    }

    // MARK: - 作例

    private var camera: CameraID { model.returnSelection }

    private var detail: some View {
        VStack(alignment: .leading, spacing: Theme.Purchase.gap) {
            HStack(spacing: 12) {
                Button { onBack(model.returnSelection) } label: {
                    Text("戻る").font(Theme.FilmLoad.secondary)
                        .frame(height: Theme.Layout.iconSize)
                        .padding(.horizontal, 16)
                        .background(Theme.Common.button, in: Capsule())
                }
                Text("作例").font(Theme.Purchase.note).foregroundStyle(Theme.Common.subText)
            }
            GeometryReader { proxy in
                let large = Theme.Purchase.largeSample
                let small = Theme.Purchase.smallSample
                let scale = min(1, proxy.size.height / large.height, (proxy.size.width - 250) / (large.width + small.width + 10))
                HStack(alignment: .top, spacing: Theme.Purchase.columnGap) {
                    samples(scale: scale)
                    info.frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.vertical, 14)
    }

    private func samples(scale: CGFloat) -> some View {
        let list = camera.profile.samples
        let large = Theme.Purchase.largeSample
        let small = Theme.Purchase.smallSample
        return HStack(alignment: .top, spacing: 10 * scale) {
            samplePrint(list[0], size: CGSize(width: large.width * scale, height: large.height * scale),
                        padding: Theme.Purchase.largePadding, showsDate: true)
            VStack(spacing: 10 * scale) {
                ForEach(1..<3, id: \.self) { index in
                    samplePrint(list[index], size: CGSize(width: small.width * scale, height: small.height * scale),
                                padding: Theme.Purchase.smallPadding, showsDate: false)
                }
            }
        }
    }

    private func samplePrint(_ sample: (light: Color, dark: Color), size: CGSize, padding: CGFloat, showsDate: Bool) -> some View {
        SampleSwatch(light: sample.light, dark: sample.dark)
            .overlay(alignment: .bottomTrailing) {
                if showsDate {
                    Text(verbatim: "'26 08 14")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(Theme.Common.accent)
                        .padding(8)
                }
            }
            .padding(padding)
            .frame(width: size.width, height: size.height)
            .background(Theme.Purchase.paper, ignoresSafeAreaEdges: [])
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScaledCameraIllustration(camera: camera, width: Theme.Purchase.illustrationWidth)
            Text(verbatim: camera.theme.name).font(Theme.Purchase.name).lineLimit(1).minimumScaleFactor(0.7)
            Text(camera.profile.detail).font(Theme.Purchase.body).foregroundStyle(Theme.Purchase.message)
            VStack(alignment: .leading, spacing: 1) {
                Text("24枚撮り ・ 買ったら何度でも使えます")
                Text("購入すると広告が表示されなくなります")
            }
            .font(Theme.Purchase.note)
            .foregroundStyle(Theme.Common.subText)
            if let message = model.message {
                Text(message).font(Theme.Purchase.note).foregroundStyle(Theme.Common.accent)
            }
            buyButton
        }
    }

    private var buyButton: some View {
        let price = model.price
        return Button { Task { await model.buy() } } label: {
            Group {
                if let price {
                    Text("\(price)で購入")
                } else if model.purchases.isLoadingPrices {
                    Text(verbatim: "…")
                } else {
                    Text("価格を取得できませんでした")
                }
            }
            .font(Theme.FilmLoad.primary)
            .foregroundStyle(price == nil ? Theme.Common.subText : Theme.Common.background)
            .frame(height: Theme.FilmLoad.buttonHeight)
            .padding(.horizontal, 22)
            .background(price == nil ? Theme.Common.button : Theme.lightButton, in: Capsule())
        }
        .disabled(price == nil || model.isBuying)
    }

    // MARK: - 袋

    private var pack: some View {
        VStack(spacing: 14) {
            Text("新しいカメラが届きました").font(Theme.Pack.title)
            FoilPackView(style: PackStyle(item: model.request.item), tear: model.tear) { model.tear(by: $0) }
            HStack(spacing: 8) {
                Text("上のギザギザを右へなぞって開ける")
                Image(systemName: "chevron.right")
            }
            .font(Theme.Pack.hint)
            .foregroundStyle(Theme.Purchase.message)
            Button { model.openPack() } label: {
                Text("タップで開ける")
                    .font(Theme.Pack.hint)
                    .foregroundStyle(Theme.Common.subText)
                    .frame(height: Theme.Layout.iconSize)
                    .padding(.horizontal, 16)
            }
        }
    }
}
