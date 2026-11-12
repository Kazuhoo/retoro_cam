import SwiftUI

/// 縦のスライドスイッチ。上に上げると ON、1枚撮るごとに下へ戻る。
struct FlashSwitch: View {
    let isOn: Bool
    let iconColor: Color
    let onChange: (Bool) -> Void

    var body: some View {
        HStack(spacing: 8) {
            track
            VStack(spacing: 3) {
                Circle()
                    .fill(isOn ? Theme.Flash.lampOn : Theme.Flash.lampOff)
                    .frame(width: Theme.Flash.lampSize, height: Theme.Flash.lampSize)
                    .shadow(color: isOn ? Theme.Flash.lampOn : .clear, radius: 4)
                Image(systemName: "bolt")
                    .font(Theme.Text.small)
                    .foregroundStyle(iconColor)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("フラッシュ"))
        .accessibilityValue(isOn ? Text(verbatim: "ON") : Text(verbatim: "OFF"))
        .accessibilityAddTraits(.isToggle)
        .accessibilityAction { onChange(!isOn) }
    }

    private var track: some View {
        VStack {
            if !isOn { Spacer(minLength: 0) }
            knob
            if isOn { Spacer(minLength: 0) }
        }
        .padding(Theme.Flash.padding)
        .frame(width: Theme.Flash.width, height: Theme.Flash.height)
        .background(Theme.Parts.well, in: trackShape)
        .overlay { trackShape.stroke(Theme.Parts.ring, lineWidth: 1.5) }
        .contentShape(trackShape)
        .animation(.easeOut(duration: 0.1), value: isOn)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    let dy = value.translation.height
                    if dy < -Theme.Flash.dragThreshold {
                        onChange(true)
                    } else if dy > Theme.Flash.dragThreshold {
                        onChange(false)
                    } else {
                        onChange(!isOn)
                    }
                }
        )
    }

    private var trackShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Theme.Flash.cornerRadius)
    }

    private var knob: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: Theme.Flash.bumpSpacing), count: 2)
        return LazyVGrid(columns: columns, spacing: Theme.Flash.bumpSpacing) {
            ForEach(0..<4, id: \.self) { _ in
                Circle()
                    .fill(RadialGradient(colors: [Theme.Flash.bumpLight, Theme.Flash.bumpDark],
                                         center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: 7))
            }
        }
        .padding(.horizontal, 5)
        .frame(width: Theme.Flash.knobWidth, height: Theme.Flash.knobHeight)
        .background(Theme.Flash.knobColor, in: RoundedRectangle(cornerRadius: Theme.Flash.knobCornerRadius))
    }
}
