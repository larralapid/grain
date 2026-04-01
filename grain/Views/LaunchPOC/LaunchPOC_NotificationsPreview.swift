import SwiftUI
import SwiftData

struct NotificationsLaunchView: View {
    private let modelContainerBuilder: () throws -> ModelContainer

    @State private var launchPhase: NotificationsLaunchPhase = .loading
    @State private var scanLineY: CGFloat = 0
    @State private var notifications: [LaunchNotification] = []
    @State private var showNotifications = false
    @State private var barcodeOpacity: Double = 0
    @State private var didStartLoading = false

    private let isReturningUser: Bool

    init(modelContainerBuilder: @escaping () throws -> ModelContainer, isReturningUser: Bool = true) {
        self.modelContainerBuilder = modelContainerBuilder
        self.isReturningUser = isReturningUser
    }

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            switch launchPhase {
            case .loading:
                launchContent
            case .loaded(let modelContainer):
                MainTabView()
                    .modelContainer(modelContainer)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            case .failed(let message):
                failureContent(message: message)
                    .transition(.opacity)
            }
        }
        .animation(.spring(duration: 0.5), value: launchPhase)
        .task {
            await loadModelContainerIfNeeded()
        }
    }

    private var launchContent: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 80)

            // Brand header
            VStack(spacing: 4) {
                Text("GRAIN")
                    .font(GrainTheme.mono(24, weight: .bold))
                    .tracking(6)
                    .foregroundColor(GrainTheme.textPrimary)

                // Barcode decoration
                HStack(spacing: 1.5) {
                    ForEach(0..<30, id: \.self) { i in
                        Rectangle()
                            .fill(GrainTheme.textSecondary.opacity(0.4))
                            .frame(width: i % 3 == 0 ? 2 : 1,
                                   height: i % 5 == 0 ? 16 : 12)
                    }
                }
                .opacity(barcodeOpacity)
                .padding(.top, 8)
            }

            // Scan line
            Rectangle()
                .fill(GrainTheme.accent)
                .frame(width: 200, height: 1)
                .offset(y: scanLineY)
                .padding(.top, 20)

            Spacer()
                .frame(height: 40)

            // Notification cards or onboarding tips
            if showNotifications {
                if isReturningUser {
                    returningUserNotifications
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    onboardingTips
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            Spacer()

            // Status
            Text("INITIALIZING")
                .font(GrainTheme.mono(9))
                .tracking(3)
                .foregroundColor(GrainTheme.textSecondary.opacity(0.5))
                .padding(.bottom, 40)
        }
        .onAppear { startSequence() }
    }

    // MARK: - Returning User: Recent Activity Cards

    private var returningUserNotifications: some View {
        VStack(spacing: 8) {
            Text("RECENT ACTIVITY")
                .font(GrainTheme.mono(9))
                .tracking(2)
                .foregroundColor(GrainTheme.textSecondary)
                .padding(.bottom, 4)

            ForEach(notifications) { notification in
                notificationCard(notification)
            }
        }
        .padding(.horizontal, 24)
    }

    private func notificationCard(_ notification: LaunchNotification) -> some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: notification.icon)
                .font(.system(size: 14, weight: .light, design: .monospaced))
                .foregroundColor(GrainTheme.accent)
                .frame(width: 28, height: 28)
                .overlay(
                    Rectangle()
                        .stroke(GrainTheme.border, lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(GrainTheme.mono(11))
                    .foregroundColor(GrainTheme.textPrimary)
                Text(notification.subtitle)
                    .font(GrainTheme.mono(9))
                    .foregroundColor(GrainTheme.textSecondary)
            }

            Spacer()

            Text(notification.time)
                .font(GrainTheme.mono(9))
                .foregroundColor(GrainTheme.textSecondary.opacity(0.6))
        }
        .padding(12)
        .background(GrainTheme.surface)
        .overlay(
            Rectangle()
                .stroke(GrainTheme.border, lineWidth: 0.5)
        )
    }

    // MARK: - New User: Onboarding Tips

    private var onboardingTips: some View {
        VStack(spacing: 12) {
            Text("QUICK START")
                .font(GrainTheme.mono(9))
                .tracking(2)
                .foregroundColor(GrainTheme.textSecondary)
                .padding(.bottom, 4)

            tipRow(icon: "viewfinder", text: "SCAN a receipt with your camera")
            tipRow(icon: "chart.bar", text: "TRACK spending by brand and category")
            tipRow(icon: "magnifyingglass", text: "SEARCH your purchase history")
        }
        .padding(.horizontal, 24)
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .light, design: .monospaced))
                .foregroundColor(GrainTheme.accent)
                .frame(width: 20)

            Text(text)
                .font(GrainTheme.mono(11))
                .foregroundColor(GrainTheme.textPrimary)

            Spacer()
        }
        .padding(.vertical, 8)
    }

    // MARK: - Animation Sequence

    private func startSequence() {
        // Barcode fade in
        withAnimation(.easeIn(duration: 0.4)) {
            barcodeOpacity = 1
        }

        // Scan line sweep
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            scanLineY = 30
        }

        // Show notifications after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Populate mock notifications (in production: fetch from SwiftData)
            notifications = [
                LaunchNotification(
                    icon: "doc.text",
                    title: "3 receipts this week",
                    subtitle: "Total: $147.23",
                    time: "2d"
                ),
                LaunchNotification(
                    icon: "arrow.up.right",
                    title: "Grocery spending up 12%",
                    subtitle: "vs. last month",
                    time: "1w"
                ),
                LaunchNotification(
                    icon: "tag",
                    title: "New brand tracked",
                    subtitle: "Trader Joe's — 5 items",
                    time: "3d"
                )
            ]

            withAnimation(.spring(duration: 0.4)) {
                showNotifications = true
            }
        }

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
                DemoDataSeeder.seedIfNeeded(in: modelContainer.mainContext)
                launchPhase = .loaded(modelContainer)
            }
        } catch {
            await MainActor.run {
                launchPhase = .failed("Unable to initialize local storage.")
            }
        }
    }
}

private enum NotificationsLaunchPhase: Equatable {
    case loading
    case loaded(ModelContainer)
    case failed(String)

    static func == (lhs: NotificationsLaunchPhase, rhs: NotificationsLaunchPhase) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.failed(let a), .failed(let b)):
            return a == b
        case (.loaded(let a), .loaded(let b)):
            return a === b
        default:
            return false
        }
    }
}

private struct LaunchNotification: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let time: String
}

#Preview("Returning User") {
    NotificationsLaunchView(
        modelContainerBuilder: { DemoDataSeeder.makePreviewContainer() },
        isReturningUser: true
    )
}

#Preview("New User") {
    NotificationsLaunchView(
        modelContainerBuilder: { DemoDataSeeder.makePreviewContainer() },
        isReturningUser: false
    )
}
