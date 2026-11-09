import Observation
import SwiftUI

@Observable
final class PurchaseModel {
    enum Stage { case detail, pack, done }

    let request: PurchaseRequest
    let isMidRoll: Bool
    let purchases: any PurchaseProviding
    private(set) var stage: Stage
    private(set) var tear: CGFloat = 0
    private(set) var isBuying = false
    private(set) var message: LocalizedStringKey?
    private var isOpeningPack = false

    /// 破り切ってから次へ進むまでの間（モックアップのとおり）
    private static let tearSettle = 0.25

    init(request: PurchaseRequest, isMidRoll: Bool, purchases: any PurchaseProviding) {
        self.request = request
        self.isMidRoll = isMidRoll
        self.purchases = purchases
        stage = request.startsAtPack ? .pack : .detail
    }

    var price: String? { purchases.displayPrice(for: request.item) }

    /// 戻ったときにカメラを選ぶ画面で選んでおくカメラ
    var returnSelection: CameraID {
        if case .camera(let camera) = request.item { return camera }
        return request.selected
    }

    /// 「このカメラで撮る」で開けるカメラ。4台セットは、有料カメラを選んでいなければ NOIR 1600
    var cameraToOpen: CameraID {
        if case .camera(let camera) = request.item { return camera }
        return request.selected.isFree ? .charcoal : request.selected
    }

    func buy() async {
        guard !isBuying else { return }
        isBuying = true
        message = nil
        defer { isBuying = false }
        let outcome = await purchases.purchase(request.item)
        message = outcome.message
        if outcome == .purchased { stage = .pack }
    }

    /// 右へなぞった分だけ破れる（左へ戻しても元に戻らない）
    func tear(by dx: CGFloat) {
        guard dx > 0 else { return }
        tear = min(Theme.Pack.fullTear, tear + dx)
        if tear >= Theme.Pack.fullTear { finishPack() }
    }

    func openPack() {
        withAnimation(.easeOut(duration: Self.tearSettle)) { tear = Theme.Pack.fullTear }
        finishPack()
    }

    private func finishPack() {
        guard !isOpeningPack else { return }
        isOpeningPack = true
        Haptics.packTorn()
        SoundPlayer.play(.packTear)
        Task {
            try? await Task.sleep(for: .seconds(Self.tearSettle))
            stage = .done
        }
    }
}
