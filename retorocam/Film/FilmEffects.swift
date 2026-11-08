import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

/// 粒子・周辺減光・光漏れ・日付。どれもフィルムの向き（横）の画像に対して適用する。
nonisolated enum FilmEffects {

    static func addGrain(_ image: CIImage, amount: Float, size: CGFloat) -> CIImage {
        guard amount > 0, let random = CIFilter.randomGenerator().outputImage else { return image }

        // CIRandomGenerator は常に同じ模様なので、1枚ごとに位置をずらす
        let shifted = random
            .transformed(by: CGAffineTransform(translationX: CGFloat(Int.random(in: 0..<4096)),
                                               y: CGFloat(Int.random(in: 0..<4096))))
            .transformed(by: CGAffineTransform(scaleX: size, y: size))

        // R チャンネルだけを使い、0.5 を中心にしたグレーのノイズにする
        let matrix = CIFilter.colorMatrix()
        matrix.inputImage = shifted
        let a = CGFloat(amount) * 2
        matrix.rVector = CIVector(x: a, y: 0, z: 0, w: 0)
        matrix.gVector = CIVector(x: a, y: 0, z: 0, w: 0)
        matrix.bVector = CIVector(x: a, y: 0, z: 0, w: 0)
        matrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        matrix.biasVector = CIVector(x: 0.5 - a / 2, y: 0.5 - a / 2, z: 0.5 - a / 2, w: 0)
        guard let noise = matrix.outputImage?.cropped(to: image.extent) else { return image }

        let blend = CIFilter.softLightBlendMode()
        blend.inputImage = noise
        blend.backgroundImage = image
        return blend.outputImage ?? image
    }

    static func addVignette(_ image: CIImage, intensity: Float) -> CIImage {
        let filter = CIFilter.vignette()
        filter.inputImage = image
        filter.intensity = min(intensity * 1.6, 1.0)
        filter.radius = 1.6   // 実機で要調整
        return filter.outputImage?.cropped(to: image.extent) ?? image
    }

    /// フィルムの端（左右どちらか）から入るオレンジ〜赤の光
    static func addLightLeak(_ image: CIImage) -> CIImage {
        let extent = image.extent
        let fromLeft = Bool.random()
        let gradient = CIFilter.radialGradient()
        gradient.center = CGPoint(
            x: fromLeft ? extent.minX - extent.width * 0.05 : extent.maxX + extent.width * 0.05,
            y: extent.minY + extent.height * CGFloat.random(in: 0.2...0.8))
        gradient.radius0 = 0
        gradient.radius1 = Float(extent.height * CGFloat.random(in: 0.45...0.8))
        gradient.color0 = CIColor(red: 1.0, green: CGFloat.random(in: 0.35...0.6), blue: 0.15,
                                  alpha: CGFloat.random(in: 0.55...0.85))
        gradient.color1 = CIColor(red: 1.0, green: 0.2, blue: 0.1, alpha: 0)
        guard let leak = gradient.outputImage?.cropped(to: extent) else { return image }

        let blend = CIFilter.screenBlendMode()
        blend.inputImage = leak
        blend.backgroundImage = image
        return blend.outputImage ?? image
    }

    /// 右下に日付を焼き込む（例：'26 11 08）。書体は M7 で VT323 に差し替える。
    static func addDateStamp(_ image: CIImage, date: Date) -> CIImage {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "''yy MM dd"
        let text = formatter.string(from: date)

        let size = image.extent.size
        let fontSize = size.height * 0.045
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red: 1, green: 0.45, blue: 0.1, alpha: 0.8)
        shadow.shadowBlurRadius = fontSize * 0.25
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.95),
            .shadow: shadow,
        ]

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let overlay = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            let string = NSAttributedString(string: text, attributes: attributes)
            string.draw(at: CGPoint(x: size.width - string.size().width - size.width * 0.06,
                                    y: size.height * 0.86))
        }
        guard let stamp = CIImage(image: overlay) else { return image }
        return stamp.composited(over: image)
    }
}
