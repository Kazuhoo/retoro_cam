import SwiftUI

/// 袋を破ったあと、カメラが飛び出す完了画面
struct PurchaseDoneView: View {
    let item: StoreItem
    let isMidRoll: Bool
    let onFinish: () -> Void

    @State private var appeared = false

    var body: some View {
        Group {
            switch item {
            case .camera(let camera): singleLayout(camera)
            case .bundle: bundleLayout
            }
        }
        .onAppear { appeared = true }
    }

    private func singleLayout(_ camera: CameraID) -> some View {
        HStack(spacing: Theme.Purchase.doneGap) {
            popping(index: 0, spread: 0) { CameraIllustration(camera: camera) }
            messageColumn(name: Text(verbatim: camera.theme.name).font(camera.nameFont(size: Theme.Purchase.nameSize)), alignment: .leading)
        }
    }

    private var bundleLayout: some View {
        VStack(spacing: 22) {
            HStack(spacing: 12) {
                ForEach(Array(CameraID.paid.enumerated()), id: \.offset) { index, camera in
                    popping(index: index, spread: (CGFloat(index) - 1.5) * 132) {
                        ScaledCameraIllustration(camera: camera, width: Theme.Pack.illustrationWidth)
                    }
                }
            }
            messageColumn(name: Text("4台セット").font(Theme.Purchase.bundleName), alignment: .center)
        }
    }

    /// 真ん中の袋の位置から、自分の場所へ飛び出す
    private func popping(index: Int, spread: CGFloat, @ViewBuilder content: () -> some View) -> some View {
        content()
            .scaleEffect(appeared ? 1 : 0.6)
            .offset(x: appeared ? 0 : -spread, y: appeared ? 0 : 30)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.62).delay(Double(index) * 0.07), value: appeared)
    }

    private func messageColumn(name: Text, alignment: HorizontalAlignment) -> some View {
        let textAlignment: TextAlignment = alignment == .center ? .center : .leading
        return VStack(alignment: alignment, spacing: 12) {
            name
            VStack(alignment: alignment, spacing: 2) {
                if isMidRoll {
                    Text("次のカメラとして使えます。")
                    Text("今のカメラを撮り切ったら選べます。")
                } else {
                    Text("カメラが使えるようになりました。")
                    Text("いつでも、何度でも使えます。")
                }
            }
            .font(Theme.Purchase.doneBody)
            .foregroundStyle(Theme.Purchase.message)
            .multilineTextAlignment(textAlignment)
            Button(action: onFinish) {
                Group {
                    if isMidRoll { Text(verbatim: "OK") } else { Text("このカメラで撮る") }
                }
                .font(Theme.Text.develop)
                .foregroundStyle(Theme.Common.background)
                .frame(height: Theme.Status.developHeight)
                .padding(.horizontal, Theme.Status.developPadding)
                .background(Theme.Common.accent, in: Capsule())
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
    }
}
