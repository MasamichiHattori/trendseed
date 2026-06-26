import SwiftUI

struct FilterChipRow: View {
    let categories: [String]
    @Binding var selectedCategory: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selectedCategory == category ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(selectedCategory == category ? AppTheme.accent : AppTheme.surface)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
