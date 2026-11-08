//
//  FilmLook.swift
//  使い捨てカメラアプリ：撮影直後に1枚を「現像済みの見た目」に加工する処理のたたき台
//
//  手順：3:2に切り抜き → 1536×1024に縮小 → LUT（色味）→ 粒子 → 周辺減光 → 光漏れ（設定でON時のみ）→ 日付
//  設定（日付・光漏れ）は「撮った瞬間の値」を渡す。
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

struct FilmLook {
    let lutName: String        // バンドル内の .cube ファイル名（拡張子なし）
    let grain: Float           // 粒子の強さ 0〜0.1 くらい
    let grainSize: CGFloat     // 粒子の大きさ（1 = 1px）
    let vignette: Float        // 周辺減光の強さ 0〜1

    static let sunday400 = FilmLook(lutName: "SUNDAY_400", grain: 0.030, grainSize: 1.4, vignette: 0.28)
    static let noir1600  = FilmLook(lutName: "NOIR_1600",  grain: 0.060, grainSize: 2.0, vignette: 0.38)
    static let splash200 = FilmLook(lutName: "SPLASH_200", grain: 0.020, grainSize: 1.2, vignette: 0.18)
    static let album100  = FilmLook(lutName: "ALBUM_100",  grain: 0.016, grainSize: 1.0, vignette: 0.30)
    static let nite800   = FilmLook(lutName: "NITE_800",   grain: 0.045, grainSize: 1.7, vignette: 0.42)
}

final class FilmProcessor {
    static let outputSize = CGSize(width: 1536, height: 1024)   // 3:2、当時のCD書き込み相当
    private let context = CIContext()
    private var cubeCache: [String: (Data, Int)] = [:]

    /// 1枚を加工して JPEG データを返す
    func develop(_ input: CIImage, look: FilmLook, date: Date,
                 dateStamp: Bool, lightLeak: Bool) -> Data? {
        var image = cropTo3x2(input)
        image = resize(image, to: Self.outputSize)
        image = applyLUT(image, name: look.lutName)
        image = addGrain(image, amount: look.grain, size: look.grainSize)
        image = addVignette(image, intensity: look.vignette)
        if lightLeak { image = addLightLeak(image) }
        if dateStamp { image = addDateStamp(image, date: date) }

        let srgb = CGColorSpace(name: CGColorSpace.sRGB)!
        return context.jpegRepresentation(of: image, colorSpace: srgb,
                                          options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.88])
    }

    // MARK: - 切り抜き・縮小

    private func cropTo3x2(_ image: CIImage) -> CIImage {
        let e = image.extent
        let target: CGFloat = 3.0 / 2.0
        var rect = e
        if e.width / e.height > target {
            rect.size.width = e.height * target
            rect.origin.x = e.midX - rect.width / 2
        } else {
            rect.size.height = e.width / target
            rect.origin.y = e.midY - rect.height / 2
        }
        return image.cropped(to: rect)
            .transformed(by: CGAffineTransform(translationX: -rect.minX, y: -rect.minY))
    }

    private func resize(_ image: CIImage, to size: CGSize) -> CIImage {
        let f = CIFilter.lanczosScaleTransform()
        f.inputImage = image
        f.scale = Float(size.height / image.extent.height)
        f.aspectRatio = Float((size.width / image.extent.width) / (size.height / image.extent.height))
        return (f.outputImage ?? image).cropped(to: CGRect(origin: .zero, size: size))
    }

    // MARK: - LUT

    private func applyLUT(_ image: CIImage, name: String) -> CIImage {
        guard let (data, n) = loadCube(name) else { return image }
        let f = CIFilter.colorCubeWithColorSpace()
        f.inputImage = image
        f.cubeDimension = Float(n)
        f.cubeData = data
        f.colorSpace = CGColorSpace(name: CGColorSpace.sRGB)   // LUTはsRGBガンマ空間で作ってある
        return f.outputImage ?? image
    }

    /// .cube を CIColorCube 用の RGBA Float32 データに変換（並び順は .cube と同じく R が最速）
    private func loadCube(_ name: String) -> (Data, Int)? {
        if let cached = cubeCache[name] { return cached }
        guard let url = Bundle.main.url(forResource: name, withExtension: "cube"),
              let text = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        var size = 0
        var values: [Float] = []
        for line in text.split(whereSeparator: \.isNewline) {
            let s = line.trimmingCharacters(in: .whitespaces)
            if s.hasPrefix("LUT_3D_SIZE") {
                size = Int(s.split(separator: " ").last ?? "") ?? 0
                values.reserveCapacity(size * size * size * 4)
            } else if let first = s.first, first.isNumber || first == "-" || first == "." {
                let rgb = s.split(separator: " ").compactMap { Float($0) }
                guard rgb.count == 3 else { continue }
                values.append(contentsOf: [rgb[0], rgb[1], rgb[2], 1.0])
            }
        }
        guard size > 0, values.count == size * size * size * 4 else { return nil }
        let data = values.withUnsafeBufferPointer { Data(buffer: $0) }
        cubeCache[name] = (data, size)
        return (data, size)
    }

    // MARK: - 粒子・周辺減光

    private func addGrain(_ image: CIImage, amount: Float, size: CGFloat) -> CIImage {
        guard amount > 0, let random = CIFilter.randomGenerator().outputImage else { return image }
        // 乱数の R チャンネルだけを使い、0.5 を中心にしたグレーのノイズにする
        let m = CIFilter.colorMatrix()
        m.inputImage = random.transformed(by: CGAffineTransform(scaleX: size, y: size))
        let a = CGFloat(amount) * 2
        m.rVector = CIVector(x: a, y: 0, z: 0, w: 0)
        m.gVector = CIVector(x: a, y: 0, z: 0, w: 0)
        m.bVector = CIVector(x: a, y: 0, z: 0, w: 0)
        m.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        m.biasVector = CIVector(x: 0.5 - a / 2, y: 0.5 - a / 2, z: 0.5 - a / 2, w: 0)
        guard let noise = m.outputImage?.cropped(to: image.extent) else { return image }
        let blend = CIFilter.softLightBlendMode()
        blend.inputImage = noise
        blend.backgroundImage = image
        return blend.outputImage ?? image
    }

    private func addVignette(_ image: CIImage, intensity: Float) -> CIImage {
        let f = CIFilter.vignette()
        f.inputImage = image
        f.intensity = min(intensity * 1.6, 1.0)   // CIVignette の intensity は 0〜1
        f.radius = 1.6                            // 0〜2。大きいほど暗くなる範囲が外側に寄る（実機で要調整）
        return f.outputImage ?? image
    }

    // MARK: - 光漏れ（設定でONのときだけ）

    private func addLightLeak(_ image: CIImage) -> CIImage {
        let e = image.extent
        // フィルムの端（左右どちらか）から入るオレンジ〜赤の光
        let fromLeft = Bool.random()
        let center = CGPoint(x: fromLeft ? e.minX - e.width * 0.05 : e.maxX + e.width * 0.05,
                             y: e.minY + e.height * CGFloat.random(in: 0.2...0.8))
        let g = CIFilter.radialGradient()
        g.center = center
        g.radius0 = 0
        g.radius1 = Float(e.height * CGFloat.random(in: 0.45...0.8))
        g.color0 = CIColor(red: 1.0, green: CGFloat.random(in: 0.35...0.6), blue: 0.15, alpha: CGFloat.random(in: 0.55...0.85))
        g.color1 = CIColor(red: 1.0, green: 0.2, blue: 0.1, alpha: 0)
        guard let leak = g.outputImage?.cropped(to: e) else { return image }
        let blend = CIFilter.screenBlendMode()
        blend.inputImage = leak
        blend.backgroundImage = image
        return blend.outputImage ?? image
    }

    // MARK: - 日付

    private func addDateStamp(_ image: CIImage, date: Date) -> CIImage {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "''yy MM dd"                       // 例：'26 11 08
        let text = df.string(from: date)

        let size = image.extent.size
        let fontSize = size.height * 0.045
        // 7セグ風の書体を同梱するとより当時らしくなる（ライセンスに注意）
        let font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .semibold)
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red: 1, green: 0.45, blue: 0.1, alpha: 0.8)
        shadow.shadowBlurRadius = fontSize * 0.25
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.95),
            .shadow: shadow
        ]
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let overlay = renderer.image { _ in
            let str = NSAttributedString(string: text, attributes: attrs)
            let w = str.size().width
            str.draw(at: CGPoint(x: size.width - w - size.width * 0.06, y: size.height * 0.86))
        }
        guard let stamp = CIImage(image: overlay) else { return image }
        return stamp.composited(over: image)
    }
}
