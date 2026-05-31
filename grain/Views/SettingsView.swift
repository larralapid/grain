import SwiftUI
import SwiftData
import FoundationModels

struct SettingsView: View {
    @ObservedObject private var appearance = AppearanceManager.shared
    @Query private var receipts: [Receipt]
    @AppStorage("ai.enabled") private var aiEnabled = true
    @AppStorage("ai.claude.enabled") private var claudeEnabled = false
    @State private var apiKeyInput = ""
    @State private var showingReviewQueue = false

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    Text("grain")
                        .font(GrainTheme.mono(11))
                        .tracking(2.2)
                        .foregroundColor(GrainTheme.textSecondary)
                        .padding(.top, 16)

                    Text("settings")
                        .font(GrainTheme.mono(14))
                        .tracking(0.5)
                        .foregroundColor(GrainTheme.textSecondary)
                        .textCase(.lowercase)
                        .padding(.top, 4)
                        .padding(.bottom, 24)

                    // Appearance toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Appearance")
                                .font(GrainTheme.mono(13))
                                .foregroundColor(GrainTheme.textPrimary)
                                .tracking(0.2)

                            Text(appearance.isDarkMode ? "dark mode" : "light mode")
                                .font(GrainTheme.mono(12))
                                .foregroundColor(GrainTheme.textSecondary)
                                .tracking(0.1)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { !appearance.isDarkMode },
                            set: { appearance.isDarkMode = !$0 }
                        ))
                        .labelsHidden()
                        .tint(GrainTheme.accent)
                    }
                    .padding(.vertical, 20)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(GrainTheme.border)
                            .frame(height: 1)
                    }

                    aiSection

                    Button {
                        showingReviewQueue = true
                    } label: {
                        settingRow(
                            label: "Review Queue",
                            description: "Receipts you flagged as incorrect, to correct."
                        )
                    }
                    .buttonStyle(.plain)

                    settingRow(
                        label: "Categories",
                        description: "Customize the categories used to organize your receipts."
                    )
                    settingRow(
                        label: "Tax Deductions",
                        description: "Configure which categories qualify for tax deduction tracking."
                    )
                    exportRow

                    settingRow(
                        label: "About Grain",
                        description: "Version, acknowledgements, and privacy policy."
                    )
                }
                .padding(.horizontal, 24)
            }
        }
        .sheet(isPresented: $showingReviewQueue) {
            ReceiptReviewQueueView()
        }
    }

    // Export Data: writes receipts to a temp CSV and presents the share sheet.
    // ShareLink needs a non-optional item, so we disable the row when there is
    // nothing to export or the file could not be written.
    @ViewBuilder
    private var exportRow: some View {
        if let url = exportCSVURL {
            ShareLink(item: url) {
                settingRow(
                    label: "Export Data",
                    description: "Download your \(receipts.count) receipt\(receipts.count == 1 ? "" : "s") as a CSV, one row per item."
                )
            }
            .buttonStyle(.plain)
        } else {
            settingRow(
                label: "Export Data",
                description: receipts.isEmpty
                    ? "Nothing to export yet \u{2014} scan a receipt first."
                    // Non-empty + no URL means the CSV write failed (vs. nothing to export).
                    : "Couldn\u{2019}t prepare the export file \u{2014} free up some storage and try again."
            )
            .opacity(0.5)
        }
    }

    // Builds the CSV file on demand. A stable, timestamped name keeps each
    // export distinct while remaining valid for the share sheet.
    private var exportCSVURL: URL? {
        guard !receipts.isEmpty else { return nil }
        let stamp = CSVExporter.isoDate(Date())
        return try? CSVExporter.writeCSV(from: receipts, fileName: "grain-export-\(stamp)")
    }

    private var aiSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI EXTRACTION")
                .font(GrainTheme.mono(10))
                .tracking(1.4)
                .foregroundColor(GrainTheme.textSecondary)

            HStack {
                Text("on-device AI")
                    .font(GrainTheme.mono(12))
                    .foregroundColor(GrainTheme.textPrimary)
                Spacer()
                Text(onDeviceStatus)
                    .font(GrainTheme.mono(11))
                    .foregroundColor(GrainTheme.textSecondary)
            }

            Toggle(isOn: $aiEnabled) {
                Text("use AI extraction")
                    .font(GrainTheme.mono(12))
                    .foregroundColor(GrainTheme.textPrimary)
            }
            .tint(GrainTheme.accent)

            Toggle(isOn: $claudeEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("advanced: use my Claude key")
                        .font(GrainTheme.mono(12))
                        .foregroundColor(GrainTheme.textPrimary)
                    Text("sends receipt image + text to Anthropic")
                        .font(GrainTheme.mono(9))
                        .foregroundColor(GrainTheme.textSecondary)
                }
            }
            .tint(GrainTheme.accent)

            if claudeEnabled {
                SecureField("anthropic api key (sk-ant-...)", text: $apiKeyInput)
                    .font(GrainTheme.mono(11))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(10)
                    .overlay(Rectangle().stroke(GrainTheme.border, lineWidth: 1))
                    .onChange(of: apiKeyInput) { _, newValue in
                        AIConfig.setClaudeAPIKey(newValue)
                    }

                Text("stored only in your device Keychain \u{00B7} never in the app bundle")
                    .font(GrainTheme.mono(9))
                    .foregroundColor(GrainTheme.textSecondary)
            }
        }
        .padding(.vertical, 20)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 1)
        }
        .onAppear { apiKeyInput = AIConfig.claudeAPIKey ?? "" }
    }

    private var onDeviceStatus: String {
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                return "available"
            case .unavailable:
                return "unavailable"
            }
        } else {
            return "requires iOS 26"
        }
    }

    private func settingRow(label: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(GrainTheme.mono(13))
                .foregroundColor(GrainTheme.textPrimary)
                .tracking(0.2)

            Text(description)
                .font(GrainTheme.mono(12))
                .foregroundColor(GrainTheme.textSecondary)
                .lineSpacing(3)
                .tracking(0.1)
        }
        .padding(.vertical, 20)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 1)
        }
    }
}

#Preview {
    SettingsView()
}
