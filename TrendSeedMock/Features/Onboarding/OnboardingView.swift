import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms = false
    @State private var currentStep = 0
    @State private var hasAgreed = false
    @State private var selectedDocument: LegalDocument?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $currentStep) {
                    onboardingStep(
                        title: "トレンドseedへ、\nようこそ",
                        body: "流行調査から分析、企画化まで進めて、\n制作プロンプト作成までつなげます。",
                        systemImage: "sparkles.tv"
                    ) {
                        onboardingOverviewVisual
                    }
                    .tag(0)

                    consentStep
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))

                footer
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(.ultraThinMaterial)
            }
            .background(AppTheme.grouped.ignoresSafeArea())
            .navigationDestination(item: $selectedDocument) { document in
                LegalDocumentView(document: document)
            }
        }
    }

    private var footer: some View {
        Button(action: primaryAction) {
            Text(primaryButtonTitle)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(primaryButtonEnabled ? AppTheme.accent : AppTheme.textSecondary.opacity(0.35))
                )
        }
        .buttonStyle(.plain)
        .disabled(!primaryButtonEnabled)
    }

    private var consentStep: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 10) {
                Text("利用開始前の確認")
                    .font(.largeTitle.bold())

                Text("ご利用前に、利用規約とプライバシーポリシーをご確認ください。")
                    .font(.title3)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(4)
            }

            VStack(spacing: 12) {
                legalLinkButton(document: .terms)
                legalLinkButton(document: .privacy)
            }

            Button {
                hasAgreed.toggle()
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: hasAgreed ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundStyle(hasAgreed ? AppTheme.accent : AppTheme.textSecondary)

                    Text("利用規約とプライバシーポリシーに同意します")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)

                    Spacer()
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(AppTheme.elevated)
                )
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)
        }
        .padding(24)
    }

    private func onboardingStep<Visual: View>(
        title: String,
        body: String,
        systemImage: String,
        @ViewBuilder visual: () -> Visual
    ) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            headerIcon(systemImage: systemImage)

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 34, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)

                Text(body)
                    .font(.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(5)
                    .lineLimit(3)
                    .minimumScaleFactor(0.9)
                    .fixedSize(horizontal: false, vertical: true)
            }

            visual()

            Spacer(minLength: 0)
        }
        .padding(24)
    }

    private var onboardingOverviewVisual: some View {
        onboardingImage(named: "onboarding-overview")
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.65), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.05), radius: 16, y: 8)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppTheme.elevated)
            )
    }

    @ViewBuilder
    private func onboardingImage(named imageName: String) -> some View {
        if let uiImage = UIImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if
            let resourceURL = Bundle.main.url(forResource: imageName, withExtension: "png"),
            let uiImage = UIImage(contentsOfFile: resourceURL.path)
        {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.accent.opacity(0.18), Color.orange.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Image(systemName: "photo")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppTheme.accent.opacity(0.7))
                }
                .frame(height: 240)
        }
    }

    private func legalLinkButton(document: LegalDocument) -> some View {
        Button {
            selectedDocument = document
        } label: {
            HStack {
                Text(document.title)
                    .font(.headline)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .foregroundStyle(.primary)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppTheme.elevated)
            )
        }
        .buttonStyle(.plain)
    }

    private func headerIcon(systemImage: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.accent.opacity(0.16), Color.orange.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 92, height: 92)

            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
        }
    }

    private var primaryButtonTitle: String {
        switch currentStep {
        case 0:
            "はじめる"
        default:
            "同意して始める"
        }
    }

    private var primaryButtonEnabled: Bool {
        currentStep == 0 || hasAgreed
    }

    private func primaryAction() {
        if currentStep < 1 {
            withAnimation(.easeInOut) {
                currentStep += 1
            }
        } else if hasAgreed {
            hasAcceptedTerms = true
        }
    }
}

#Preview {
    OnboardingView()
}
