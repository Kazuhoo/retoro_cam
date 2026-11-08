import Observation

@Observable
final class AppRouter {
    enum Screen {
        case shooting, sendLab, darkroom
        case prints(Roll)
    }

    var screen: Screen = .shooting
}
