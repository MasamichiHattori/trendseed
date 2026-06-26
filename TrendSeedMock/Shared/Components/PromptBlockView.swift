import SwiftUI

struct PromptBlockView: View {
    let prompt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("制作プロンプト", systemImage: "doc.on.doc")
                    .font(.headline)

                Spacer()

                Text("Copy Ready")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.accent.opacity(0.12), in: Capsule())
            }

            Text(prompt)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.white.opacity(0.94))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.black.opacity(0.92), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppTheme.elevated)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.accent.opacity(0.20), lineWidth: 1)
        }
        .environment(\.colorScheme, .light)
    }
}
