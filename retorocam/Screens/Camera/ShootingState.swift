import CoreGraphics

/// 巻き上げと残り枚数の決まり。撮影済みの枚数は保存済みと処理中のコマを合わせて渡す。
struct ShootingState {
    static let totalFrames = 24
    static let fullWind: CGFloat = 140
    static let detent: CGFloat = 20

    enum WindResult: Equatable {
        case ignored, bounced, advanced(crossedDetent: Bool), completed
    }

    private(set) var isWound = true
    private(set) var windDistance: CGFloat = 0
    /// ダイヤルの溝の位置
    private(set) var spin: CGFloat = 0

    var windProgress: CGFloat { windDistance / Self.fullWind }

    func isEmpty(exposed: Int) -> Bool { exposed >= Self.totalFrames }
    func canShoot(exposed: Int) -> Bool { isWound && !isEmpty(exposed: exposed) }

    /// 窓に出す数字。撮った直後は巻き上げるまで前の数字のまま。
    func displayedRemaining(exposed: Int) -> Int {
        if isEmpty(exposed: exposed) { return 0 }
        return Self.totalFrames - exposed + (isWound ? 0 : 1)
    }

    mutating func markShot() {
        isWound = false
        windDistance = 0
    }

    /// 撮ったコマを取り消して、巻き上げ済みに戻す
    mutating func restoreWound() {
        isWound = true
        windDistance = 0
    }

    mutating func wind(by dx: CGFloat, exposed: Int) -> WindResult {
        guard dx > 0, !isEmpty(exposed: exposed) else { return .ignored }
        guard !isWound else { return .bounced }

        spin += dx
        let next = windDistance + dx
        if next >= Self.fullWind {
            restoreWound()
            return .completed
        }
        let crossed = floor(next / Self.detent) != floor(windDistance / Self.detent)
        windDistance = next
        return .advanced(crossedDetent: crossed)
    }
}
