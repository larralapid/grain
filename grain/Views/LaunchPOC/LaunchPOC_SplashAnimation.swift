import SwiftUI
import SwiftData

struct LaunchExperienceView: View {
    private let modelContainerBuilder: () throws -> ModelContainer

    @State private var launchPhase: LaunchPhase = .loading
    @State private var lineOffset: CGFloat = -200
    @State private var opacity: Double = 0
    @State private var receiptLines: [ReceiptLine] = []
    @State private var didStartLoading = false

    init(modelContainerBuilder: @escaping () throws -> ModelContainer) {
        self.modelContainerBuilder = modelContainerBuilder
    }

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            switch launchPhase {
            case .loading:
                splashContent
            case .loaded(let modelContainer):
                MainTabView()
                    .modelContainer(modelContainer)
                    .transition(.opacity)
            case .failed(let message):
                failureContent(message: message)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: launchPhase)
        .task {
            await loadModelContainerIfNeeded()
        }
    }

    private var splashContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // App name
            Text("GRAIN")
                .font(GrainTheme.mono(28, weight: .bold))
                .tracking(8)
                .foregroundColor(GrainTheme.textPrimary)
                .opacity(opacity)

            Text("receipt scanner")
                .font(GrainTheme.mono(11))
                .tracking(2)
                .foregroundColor(GrainTheme.textSecondary)
                .opacity(opacity)
                .padding(.top, 4)

            Spacer()
                .frame(height: 40)

            // Animated receipt unrolling
            receiptAnimation
                .frame(height: 200)
                .clipped()

            Spacer()

            // Scan line animation
            scanLineIndicator
                .padding(.bottom, 60)
        }
        .onAppear {
            startAnimations()
        }
    }

    private var receiptAnimation: some View {
        VStack(spacing: 0) {
            // Torn edge
            HStack(spacing: 2) {
                ForEach(0..<30, id: \.self) { _ in
                    Rectangle()
                        .fill(GrainTheme.surface)
                        .frame(width: 4, height: 6)
                }
            }

            // Receipt body with animated lines
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(GrainTheme.surface)
                    .frame(width: 140)

                VStack(spacing: 6) {
                    ForEach(receiptLines) { line in
                        HStack {
                            Rectangle()
                                .fill(GrainTheme.textSecondary.opacity(0.3))
                                .frame(width: line.width, height: 2)
                            Spacer()
                            if line.hasAmount {
                                Rectangle()
                                    .fill(GrainTheme.textSecondary.opacity(0.3))
                                    .frame(width: 28, height: 2)
                            }
                        }
                        .padding(.horizontal, 12)
                        .opacity(line.opacity)
                    }
                }
                .padding(.top, 12)
            }
            .frame(width: 140)
        }
    }

    private var scanLineIndicator: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(GrainTheme.accent.opacity(0.6))
                .frame(width: 120, height: 1)
                .offset(y: lineOffset)

            Text("LOADING")
                .font(GrainTheme.mono(9))
                .tracking(3)
                .foregroundColor(GrainTheme.textSecondary)
        }
    }

    private func failureContent(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()

            Text("GRAIN")
                .font(GrainTheme.mono(28, weight: .bold))
                .tracking(8)
                .foregroundColor(GrainTheme.textPrimary)

            VStack(spacing: 8) {
                Text("LAUNCH FAILED")
                    .font(GrainTheme.mono(11, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(GrainTheme.textPrimary)

                Text(message)
                    .font(GrainTheme.mono(11))
                    .foregroundColor(GrainTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button("Retry") {
                launchPhase = .loading
                didStartLoading = false
            }
            .font(GrainTheme.mono(11, weight: .semibold))
            .foregroundColor(GrainTheme.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(GrainTheme.surface)
            .overlay(
                Rectangle()
                    .stroke(GrainTheme.border, lineWidth: 0.5)
            )

            Spacer()
        }
    }

    private func startAnimations() {
        guard receiptLines.isEmpty else { return }

        // Fade in title
        withAnimation(.easeIn(duration: 0.3)) {
            opacity = 1
        }

        // Generate receipt lines progressively
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.easeIn(duration: 0.2)) {
                    receiptLines.append(ReceiptLine(
                        width: CGFloat.random(in: 40...90),
                        hasAmount: i > 1 && i < 7,
                        opacity: 1
                    ))
                }
            }
        }

        // Scan line bounce
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            lineOffset = 10
        }
    }

    private func loadModelContainerIfNeeded() async {
        guard !didStartLoading else { return }
        didStartLoading = true
        let builder = modelContainerBuilder

        do {
            let modelContainer = try await Task.detached(priority: .userInitiated) {
                try builder()
            }.value

            await MainActor.run {
                launchPhase = .loaded(modelContainer)
            }
        } catch {
            await MainActor.run {
                launchPhase = .failed("Unable to initialize local storage.")
            }
        }
    }
}

private struct ReceiptLine: Identifiable {
    let id = UUID()
    let width: CGFloat
    let hasAmount: Bool
    let opacity: Double
}

private enum LaunchPhase: Equatable {
    case loading
    case loaded(ModelContainer)
    case failed(String)

    static func == (lhs: LaunchPhase, rhs: LaunchPhase) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.failed(let lhsMessage), .failed(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.loaded, .loaded):
            return false
        default:
            return false
        }
    }
}

#Preview {
    LaunchExperienceView {
        let schema = Schema([
            Receipt.self,
            ReceiptItem.self,
            Product.self,
            PricePoint.self,
            Brand.self,
            BankTransaction.self,
            SpendingAnalytics.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
        .modelContainer(for: [Receipt.self, ReceiptItem.self, Product.self, Brand.self, BankTransaction.self, SpendingAnalytics.self], inMemory: true)
}
