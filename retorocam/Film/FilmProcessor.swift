import CoreImage
import CoreImage.CIFilterBuiltins
import ImageIO

/// 撮影直後の1枚を「現像済みの見た目」に加工する。
///
/// 本物の使い捨てカメラと同じく、縦持ちの写真もフィルムの向き（横）のまま加工して
/// 日付を焼き込み、最後に縦へ回す。縦で見ると日付は右上で、下から上へ年月日と読む向きになる。
actor FilmProcessor {
    static let outputSize = CGSize(width: 1536, height: 1024)

    private let context = CIContext()
    private var cubes: [String: LUTCube] = [:]

    /// - Parameters:
    ///   - photoData: 撮影データ（EXIF の向きを適用して読む）
    ///   - isPortrait: 縦持ちで撮ったか
    /// - Returns: 加工後の JPEG データ
    func develop(photoData: Data, look: FilmLook, date: Date,
                 isPortrait: Bool, options: CaptureOptions) -> Data? {
        guard let upright = CIImage(data: photoData, options: [.applyOrientationProperty: true]) else {
            return nil
        }

        // フィルムの向き（横）にそろえる
        var image = isPortrait ? upright.oriented(.right) : upright
        image = cropTo3x2(image)
        image = resize(image, to: Self.outputSize)
        image = applyLUT(image, name: look.lutName)
        image = FilmEffects.addGrain(image, amount: look.grain, size: look.grainSize)
        image = FilmEffects.addVignette(image, intensity: look.vignette)
        if options.lightLeak { image = FilmEffects.addLightLeak(image) }
        if options.dateStamp { image = FilmEffects.addDateStamp(image, date: date) }

        if isPortrait { image = image.oriented(.left) }
        image = image.transformed(by: CGAffineTransform(
            translationX: -image.extent.minX, y: -image.extent.minY))

        guard let srgb = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        return context.jpegRepresentation(
            of: image, colorSpace: srgb,
            options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.88])
    }

    // MARK: - 切り抜き・縮小

    private func cropTo3x2(_ image: CIImage) -> CIImage {
        let extent = image.extent
        let target: CGFloat = 3.0 / 2.0
        var rect = extent
        if extent.width / extent.height > target {
            rect.size.width = extent.height * target
            rect.origin.x = extent.midX - rect.width / 2
        } else {
            rect.size.height = extent.width / target
            rect.origin.y = extent.midY - rect.height / 2
        }
        return image.cropped(to: rect)
            .transformed(by: CGAffineTransform(translationX: -rect.minX, y: -rect.minY))
    }

    private func resize(_ image: CIImage, to size: CGSize) -> CIImage {
        let filter = CIFilter.lanczosScaleTransform()
        filter.inputImage = image
        filter.scale = Float(size.height / image.extent.height)
        filter.aspectRatio = Float((size.width / image.extent.width) / (size.height / image.extent.height))
        return (filter.outputImage ?? image).cropped(to: CGRect(origin: .zero, size: size))
    }

    // MARK: - LUT

    private func applyLUT(_ image: CIImage, name: String) -> CIImage {
        guard let cube = cube(named: name) else { return image }
        let filter = CIFilter.colorCubeWithColorSpace()
        filter.inputImage = image
        filter.cubeDimension = Float(cube.dimension)
        filter.cubeData = cube.data
        filter.colorSpace = CGColorSpace(name: CGColorSpace.sRGB)   // LUT は sRGB ガンマ空間で作ってある
        return filter.outputImage ?? image
    }

    private func cube(named name: String) -> LUTCube? {
        if let cached = cubes[name] { return cached }
        let loaded = LUTLoader.load(named: name)
        cubes[name] = loaded
        return loaded
    }
}
