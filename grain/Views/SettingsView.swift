import SwiftUI

struct SettingsView: View {
    @ObservedObject private var appearance = AppearanceManager.shared

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

                    settingRow(
                        label: "Categories",
                        description: "Customize the categories used to organize your receipts."
                    )
                    settingRow(
                        label: "Tax Deductions",
                        description: "Configure which categories qualify for tax deduction tracking."
                    )
                    settingRow(
                        label: "Export Data",
                        description: "Download your receipts and analytics as CSV or PDF."
                    )
                    settingRow(
                        label: "About Grain",
                        description: "Version, acknowledgements, and privacy policy."
                    )
                }
                .padding(.horizontal, 24)
            }
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
