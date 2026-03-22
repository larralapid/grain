# Grain - Receipt Scanner & Expense Tracker

Grain is a comprehensive iOS app that scans receipts and tracks expenses down to the most granular level. Track your products, brands, and spending patterns with powerful analytics and insights.

**[Changelog](CHANGELOG.md)** · **[Wiki](../../wiki)** · **[Architecture Decisions](wiki/adr/README.md)** · **[Current State](wiki/Current-State.md)**

## Features

### 📱 Receipt Scanning
- Camera-based receipt scanning with OCR
- Automatic extraction of merchant, date, items, and prices
- Support for various receipt formats and layouts
- Manual editing and correction of scanned data

### 📊 Expense Analytics
- Detailed spending breakdowns by category, brand, and merchant
- Weekly, monthly, quarterly, and yearly reports
- Spending trends and patterns analysis
- Tax-deductible expense tracking

### 🏷️ Product & Brand Tracking
- Automatic product categorization and brand recognition
- Price history tracking for individual products
- Brand spending analysis
- Product-level expense insights

### 💰 Financial Insights
- Total spending summaries
- Average transaction amounts
- Category-wise expense distribution
- Tax preparation assistance

### 🔗 Bank Integration (Coming Soon)
- Link receipts to bank transactions
- Automatic transaction matching
- Enhanced accuracy through dual verification

## Technical Stack

- **Framework**: SwiftUI + SwiftData
- **Platform**: iOS 17.0+
- **Language**: Swift 5.9+
- **OCR**: Vision Framework
- **Database**: SwiftData with Core Data backend
- **Charts**: Swift Charts framework

## Installation

1. Clone the repository
2. Open `grain.xcodeproj` in Xcode 15+
3. Build and run on iOS device or simulator

## Usage

1. **Scan Receipt**: Use the camera tab to photograph your receipt
2. **Review & Edit**: Check the extracted data and make corrections if needed
3. **Save**: Store the receipt with all item details
4. **Analytics**: View spending insights in the Analytics tab
5. **Track Products**: Monitor your favorite brands and products

## Documentation

- [Current State Assessment](CURRENT_STATE.md) — audit of what's built, what's broken, and what's next
- [Redesign Spec](docs/redesign-spec.md) — inspiration analysis, design system, and three wireframe directions

## Future Enhancements

- AI-powered expense categorization
- MCP (Model Context Protocol) integration
- Class action lawsuit notifications
- Rebate tracking and alerts
- Export functionality for tax software
- Bank account integration
- Receipt image enhancement
- Multi-language OCR support

## Privacy & Security

- All data is stored locally on your device
- No cloud sync or external data sharing
- Receipt images are processed on-device
- Bank integration uses secure, encrypted connections

## Contributing

This is a proprietary project. Contributions are currently not accepted.

## License

All rights reserved. This software is proprietary and confidential.

## Contact

For questions or support, please create an issue in this repository.

---

*Grain helps you take control of your finances, one receipt at a time.*