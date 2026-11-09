import Foundation

/// 売っているもの（spec §8）
enum StoreItem: Hashable {
    case camera(CameraID)
    case bundle

    private var suffix: String {
        switch self {
        case .camera(.charcoal): "noir1600"
        case .camera(.pool): "splash200"
        case .camera(.green): "album100"
        case .camera(.party): "nite800"
        case .camera(.sunshine): "free"
        case .bundle: "bundle4"
        }
    }

    var productID: String {
        "\(Bundle.main.bundleIdentifier ?? "com.kazuho.retorocam").camera.\(suffix)"
    }

    /// 買うと使えるようになるカメラ
    var unlocks: Set<CameraID> {
        switch self {
        case .camera(let camera): [camera]
        case .bundle: Set(CameraID.paid)
        }
    }

    static var all: [StoreItem] { CameraID.paid.map(StoreItem.camera) + [.bundle] }
}

extension CameraID {
    static var paid: [CameraID] { allCases.filter { !$0.isFree } }
    var isFree: Bool { self == .sunshine }
}
