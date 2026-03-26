import SwiftUI

private enum ScanMode: String, CaseIterable {
    case document
    case guided
    case live

    var title: String {
        switch self {
        case .document:
            "document"
        case .guided:
            "guided"
        case .live:
            "live"
        }
    }

    var detail: String {
        switch self {
        case .document:
            "best default: perspective correction + ocr review"
        case .guided:
            "auto-capture after a stable hold"
        case .live:
            "raw edge detection + manual capture"
        }
    }
}

struct ReceiptScannerView: View {
    @State private var selectedMode: ScanMode = .document

    var body: some View {
        ZStack {
            selectedScanner
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            modePickerChrome
        }
    }

    @ViewBuilder
    private var selectedScanner: some View {
        switch selectedMode {
        case .document:
            ScanPOC_DocumentScanner()
        case .guided:
            ScanPOC_GuidedCapture()
        case .live:
            ScanPOC_LiveCamera()
        }
    }

    private var modePickerChrome: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("scan")
                .font(GrainTheme.mono(10))
                .tracking(2)
                .foregroundColor(GrainTheme.textSecondary)

            Text(selectedMode.detail)
                .font(GrainTheme.mono(11))
                .foregroundColor(GrainTheme.dateHeader)
                .tracking(0.3)

            HStack(spacing: 8) {
                ForEach(ScanMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMode = mode
                        }
                    } label: {
                        Text(mode.title)
                            .font(GrainTheme.mono(11, weight: selectedMode == mode ? .semibold : .regular))
                            .tracking(0.8)
                            .foregroundColor(selectedMode == mode ? GrainTheme.textPrimary : GrainTheme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Rectangle()
                                    .stroke(
                                        selectedMode == mode ? GrainTheme.textPrimary : GrainTheme.border,
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(GrainTheme.bg.opacity(0.96))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GrainTheme.border)
                .frame(height: 1)
        }
    }
}

#Preview {
    ReceiptScannerView()
}
