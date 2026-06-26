import SwiftUI

struct LegalDocumentView: View {
    let document: LegalDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(document.title)
                    .font(.largeTitle.bold())

                ForEach(Array(document.sections.enumerated()), id: \.offset) { _, section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(.headline)

                        Text(section.body)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .lineSpacing(4)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(AppTheme.elevated)
                    )
                }
            }
            .padding()
        }
        .background(AppTheme.grouped.ignoresSafeArea())
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LegalDocumentView(document: .terms)
    }
}
