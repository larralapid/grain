import SwiftUI
import SwiftData

// MARK: - POC 1: Async ModelContainer Init with Splash Animation
// Ref: Issue #20 — Reduce app cold start time / add launch experience
//
// Strategy: Move ModelContainer creation to async Task, show branded
// splash screen with receipt-themed animation while loading.

struct SplashAnimationView: View {
    @ObservedObject private var appearance = AppearanceManager.shared
    @State private var isLoaded = false
    @State private var lineOffset: CGFloat = -200
    @State private var opacity: Double = 0
    @State private var receiptLines: [ReceiptLine] = []

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            if isLoaded {
                // Transition to main app
                MainTabView()
                    .transition(.opacity)
            } else {
                splashContent
            }
        }
        .animation(.easeInOut(duration: 0.4), value: isLoaded)
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

    private func startAnimations() {
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

        // Simulate load complete
        // In production: replace with actual ModelContainer init callback
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isLoaded = true
        }
    }
}

private struct ReceiptLine: Identifiable {
    let id = UUID()
    let width: CGFloat
    let hasAmount: Bool
    let opacity: Double
}

// MARK: - App Entry Point (POC 1)
// Replace grainApp.swift body with:
//
// struct grainApp: App {
//     var body: some Scene {
//         WindowGroup {
//             SplashAnimationView()
//         }
//     }
// }
// Then init ModelContainer async in SplashAnimationView.onAppear

#Preview {
    SplashAnimationView()
        .modelContainer(for: [Receipt.self, ReceiptItem.self, Product.self, Brand.self, BankTransaction.self, SpendingAnalytics.self], inMemory: true)
}
