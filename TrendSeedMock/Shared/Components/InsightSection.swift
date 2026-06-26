import SwiftUI

struct InsightSection: View {
    let title: String
    let bodyText: String
    var emphasis: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            Text(bodyText)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(emphasis ? AppTheme.accent.opacity(0.10) : AppTheme.elevated)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(emphasis ? AppTheme.accent.opacity(0.35) : Color.black.opacity(0.05), lineWidth: 1)
        }
    }
}
