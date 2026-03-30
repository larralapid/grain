import SwiftUI
import SwiftData

// MARK: - POC 2: Skeleton UI + Progressive Loading
// Ref: Issue #20 — Reduce app cold start time / add launch experience
//
// Strategy: Show the main tab view skeleton immediately with placeholder
// shimmer content. Load ModelContainer in background, populate when ready.
// Users see structure instantly — content fills in progressively.

struct SkeletonLaunchView: View {
    private let modelContainerBuilder: () throws -> ModelContainer

    @State private var launchPhase: SkeletonLaunchPhase = .loading
    @State private var selectedTab = 0
    @State private var didStartLoading = false

    init(modelContainerBuilder: @escaping () throws -> ModelContainer) {
        self.modelContainerBuilder = modelContainerBuilder
    }

    var body: some View {
        ZStack {
            switch launchPhase {
            case .loading:
                skeletonTabs
            case .loaded(let modelContainer):
                MainTabView()
                    .modelContainer(modelContainer)
                    .transition(.opacity)
            case .failed(let message):
                failureContent(message: message)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: launchPhase)
        .task {
            await loadModelContainerIfNeeded()
        }
    }

    private var skeletonTabs: some View {
        TabView(selection: $selectedTab) {
            SkeletonReceiptList()
                .tabItem { Label("receipts", systemImage: "doc.text") }
                .tag(0)

            SkeletonScanPlaceholder()
                .tabItem { Label("scan", systemImage: "viewfinder") }
                .tag(1)

            SkeletonAnalytics()
                .tabItem { Label("analytics", systemImage: "chart.bar") }
                .tag(2)

            SkeletonProductList()
                .tabItem { Label("index", systemImage: "list.bullet") }
                .tag(3)

            Text("settings")
                .font(GrainTheme.mono(11))
                .foregroundColor(GrainTheme.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(GrainTheme.bg)
                .tabItem { Label("settings", systemImage: "gearshape") }
                .tag(4)
        }
        .tint(GrainTheme.accent)
    }

    private func failureContent(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Text("LAUNCH FAILED")
                .font(GrainTheme.mono(11, weight: .semibold))
                .tracking(2)
                .foregroundColor(GrainTheme.textPrimary)
            Text(message)
                .font(GrainTheme.mono(11))
                .foregroundColor(GrainTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Retry") {
                launchPhase = .loading
                didStartLoading = false
            }
            .font(GrainTheme.mono(11, weight: .semibold))
            .foregroundColor(GrainTheme.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(GrainTheme.surface)
            .overlay(Rectangle().stroke(GrainTheme.border, lineWidth: 0.5))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GrainTheme.bg)
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

private enum SkeletonLaunchPhase: Equatable {
    case loading
    case loaded(ModelContainer)
    case failed(String)

    static func == (lhs: SkeletonLaunchPhase, rhs: SkeletonLaunchPhase) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.failed(let a), .failed(let b)): return a == b
        case (.loaded, .loaded): return false
        default: return false
        }
    }
}

// MARK: - Skeleton Components

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        GrainTheme.textSecondary.opacity(0.08),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 300
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

struct SkeletonReceiptList: View {
    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header skeleton
                HStack {
                    Text("RECEIPTS")
                        .font(GrainTheme.mono(11))
                        .tracking(2)
                        .foregroundColor(GrainTheme.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // Month header skeleton
                skeletonBlock(width: 80, height: 10)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                // Receipt row skeletons
                ForEach(0..<6, id: \.self) { i in
                    skeletonReceiptRow
                        .padding(.horizontal, 16)
                        .padding(.top, i == 0 ? 12 : 8)
                }

                Spacer()
            }
        }
    }

    private var skeletonReceiptRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                skeletonBlock(width: CGFloat.random(in: 100...160), height: 12)
                skeletonBlock(width: CGFloat.random(in: 60...100), height: 9)
            }
            Spacer()
            skeletonBlock(width: 50, height: 12)
        }
        .padding(.vertical, 12)
        .overlay(
            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 0.5),
            alignment: .bottom
        )
        .shimmer()
    }

    private func skeletonBlock(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(GrainTheme.surface)
            .frame(width: width, height: height)
    }
}

struct SkeletonAnalytics: View {
    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("ANALYTICS")
                    .font(GrainTheme.mono(11))
                    .tracking(2)
                    .foregroundColor(GrainTheme.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                // Chart skeleton
                RoundedRectangle(cornerRadius: 2)
                    .fill(GrainTheme.surface)
                    .frame(height: 200)
                    .padding(.horizontal, 16)
                    .shimmer()

                // Breakdown rows skeleton
                ForEach(0..<4, id: \.self) { _ in
                    HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(GrainTheme.surface)
                            .frame(width: CGFloat.random(in: 80...140), height: 10)
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(GrainTheme.surface)
                            .frame(width: 50, height: 10)
                    }
                    .padding(.horizontal, 16)
                    .shimmer()
                }

                Spacer()
            }
        }
    }
}

struct SkeletonScanPlaceholder: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Spacer()
                Text("SCAN")
                    .font(GrainTheme.mono(11))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.3))
                Spacer()
            }
        }
    }
}

struct SkeletonProductList: View {
    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {
                Text("INDEX")
                    .font(GrainTheme.mono(11))
                    .tracking(2)
                    .foregroundColor(GrainTheme.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                ForEach(0..<5, id: \.self) { _ in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(GrainTheme.surface)
                            .frame(width: 36, height: 36)
                        VStack(alignment: .leading, spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(GrainTheme.surface)
                                .frame(width: CGFloat.random(in: 80...140), height: 11)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(GrainTheme.surface)
                                .frame(width: CGFloat.random(in: 50...80), height: 9)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .shimmer()
                }

                Spacer()
            }
        }
    }
}

#Preview {
    SkeletonLaunchView {
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
}
