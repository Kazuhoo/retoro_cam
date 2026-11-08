import SwiftUI

/// 写真の束。指についてきて少し傾き、下に次の写真が重なって見える。
struct PhotoStackView: View {
    let model: PrintsModel

    @State private var dragX: CGFloat = 0

    var body: some View {
        HStack(spacing: 16) {
            arrow("chevron.left", label: "前の写真", enabled: model.index > 0) { model.go(-1) }
            GeometryReader { proxy in
                let size = cardSize(in: proxy.size)
                stack(size: size)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .contentShape(Rectangle())
                    .gesture(swipe)
            }
            arrow("chevron.right", label: "次の写真", enabled: !model.isLast) { model.go(1) }
        }
    }

    private func stack(size: CGSize) -> some View {
        ZStack {
            Theme.Prints.backCard
                .frame(width: size.width, height: size.height)
                .rotationEffect(.degrees(3)).offset(x: 10)
                .shadow(color: .black.opacity(0.45), radius: 7, y: 6)
            nextCard(size: size)
                .rotationEffect(.degrees(-2)).offset(x: -6)
                .shadow(color: .black.opacity(0.45), radius: 7, y: 6)
            print(size: size)
                .rotationEffect(.degrees(dragX / 40))
                .offset(x: dragX)
                .shadow(color: .black.opacity(0.55), radius: 11, y: 10)
        }
    }

    /// 次の写真の端が、下からのぞく
    private func nextCard(size: CGSize) -> some View {
        Theme.Prints.underCard
            .overlay {
                if !model.isLast, let image = model.images[model.index + 1] {
                    Image(uiImage: image).resizable().scaledToFill()
                        .padding(Theme.Prints.border)
                }
            }
            .frame(width: size.width, height: size.height)
            .clipped()
    }

    private func print(size: CGSize) -> some View {
        Theme.Prints.paper
            .overlay {
                if let image = model.images[model.index] {
                    Image(uiImage: image).resizable().scaledToFit()
                        .padding(Theme.Prints.border)
                }
            }
            .frame(width: size.width, height: size.height)
            .accessibilityLabel(Text("写真 \(model.index + 1)枚目"))
    }

    /// 写真は 3:2 のまま余白を足す。縦長のプリントは高さいっぱいに。
    private func cardSize(in area: CGSize) -> CGSize {
        let border = Theme.Prints.border * 2
        if model.current?.isPortrait == true {
            let height = area.height - Theme.Prints.portraitMargin
            return CGSize(width: (height - border) * 2 / 3 + border, height: height)
        }
        let height = min(Theme.Prints.cardHeight, area.height)
        return CGSize(width: (height - border) * 3 / 2 + border, height: height)
    }

    private var swipe: some Gesture {
        DragGesture()
            .onChanged { dragX = $0.translation.width }
            .onEnded { value in
                let distance = value.translation.width
                if distance < -Theme.Prints.swipeThreshold {
                    model.go(1)
                } else if distance > Theme.Prints.swipeThreshold {
                    model.go(-1)
                }
                dragX = 0
            }
    }

    private func arrow(_ symbol: String, label: LocalizedStringKey, enabled: Bool,
                       action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .foregroundStyle(Theme.Common.text)
                .frame(width: Theme.Layout.iconSize, height: Theme.Layout.iconSize)
                .background(Theme.Common.button, in: Circle())
        }
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
        .accessibilityLabel(Text(label))
    }
}
