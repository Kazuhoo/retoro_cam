import SwiftUI

/// 同梱している書体のライセンス
struct LicensesScreen: View {
    private struct Entry: Identifiable {
        let name: String
        let file: String
        var id: String { file }
    }

    private static let entries = [
        Entry(name: "DM Serif Display", file: "DMSerifDisplay-LICENSE"),
        Entry(name: "Monoton", file: "Monoton-LICENSE"),
        Entry(name: "Pacifico", file: "Pacifico-LICENSE"),
        Entry(name: "Shrikhand", file: "Shrikhand-LICENSE"),
        Entry(name: "Special Elite", file: "SpecialElite-LICENSE"),
        Entry(name: "VT323", file: "VT323-LICENSE"),
    ]

    let onBack: () -> Void
    @State private var selected = LicensesScreen.entries[0]

    var body: some View {
        ZStack {
            Theme.Common.background.ignoresSafeArea()
            VStack(spacing: Theme.Settings.gap) {
                HStack {
                    Text("ライセンス").font(Theme.FilmLoad.title)
                    Spacer()
                    Button(action: onBack) {
                        Text("戻る").font(Theme.Darkroom.button)
                            .foregroundStyle(Theme.Common.text)
                            .frame(height: Theme.Layout.iconSize)
                            .padding(.horizontal, 16)
                            .background(Theme.Common.button, in: Capsule())
                    }
                }
                HStack(alignment: .top, spacing: Theme.Settings.columnGap) {
                    fontList.frame(width: 190)
                    licenseText
                }
            }
            .padding(.top, Theme.Settings.topPadding)
            .padding(.horizontal, Theme.Settings.horizontalPadding)
        }
        .foregroundStyle(Theme.Common.text)
        .statusBarHidden()
    }

    private var fontList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 6) {
                ForEach(Self.entries) { entry in
                    Button { selected = entry } label: {
                        Text(verbatim: entry.name)
                            .font(Theme.Settings.row)
                            .foregroundStyle(entry.id == selected.id ? Theme.Common.background : Theme.Common.text)
                            .frame(maxWidth: .infinity, minHeight: Theme.Layout.iconSize, alignment: .leading)
                            .padding(.horizontal, 14)
                            .background(entry.id == selected.id ? Theme.Common.accent : Theme.Common.card,
                                        in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var licenseText: some View {
        ScrollView {
            Text(verbatim: Self.text(for: selected))
                .font(Theme.Settings.footer)
                .foregroundStyle(Theme.Purchase.message)
                .frame(maxWidth: .infinity, alignment: .leading)
                .id(selected.id)
        }
    }

    private static func text(for entry: Entry) -> String {
        guard let url = Bundle.main.url(forResource: entry.file, withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8) else { return "" }
        return text
    }
}
