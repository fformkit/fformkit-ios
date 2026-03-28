import Foundation
import SwiftUI

// Matches the response from GET /api/v1/config/{apiKey}
public struct FormConfig: Codable {
    // Submission auth
    public let token: String
    public let openedAt: TimeInterval

    // Feature toggles
    public let showRating: Bool?
    public let showScreenshot: Bool?
    public let showEmail: Bool?

    // Text content
    public let formTitle: String?
    public let buttonLabel: String?
    public let placeholderText: String?
    public let successMessage: String?
    public let emailPlaceholder: String?
    public let screenshotLabel: String?
    public let screenshotIcon: String?
    public let tagline: String?

    // Colors (hex strings, e.g. "#FFFFFF")
    public let primaryColor: String?
    public let backgroundColor: String?
    public let titleColor: String?
    public let starColorActive: String?
    public let starColorInactive: String?
    public let inputBackgroundColor: String?
    public let inputBorderColor: String?
    public let placeholderColor: String?
    public let buttonTextColor: String?
    public let successColor: String?
    public let taglineColor: String?

    // Layout
    public let borderRadius: Int?
    public let theme: String?

    enum CodingKeys: String, CodingKey {
        case token, openedAt = "opened_at"
        case showRating = "show_rating"
        case showScreenshot = "show_screenshot"
        case showEmail = "show_email"
        case formTitle = "form_title"
        case buttonLabel = "button_label"
        case placeholderText = "placeholder_text"
        case successMessage = "success_message"
        case emailPlaceholder = "email_placeholder"
        case screenshotLabel = "screenshot_label"
        case screenshotIcon = "screenshot_icon"
        case tagline
        case primaryColor = "primary_color"
        case backgroundColor = "background_color"
        case titleColor = "title_color"
        case starColorActive = "star_color_active"
        case starColorInactive = "star_color_inactive"
        case inputBackgroundColor = "input_background_color"
        case inputBorderColor = "input_border_color"
        case placeholderColor = "placeholder_color"
        case buttonTextColor = "button_text_color"
        case successColor = "success_color"
        case taglineColor = "tagline_color"
        case borderRadius = "border_radius"
        case theme
    }
}

extension FormConfig {
    func color(for hex: String?, fallback: Color) -> Color {
        guard let hex else { return fallback }
        return Color(hex: hex) ?? fallback
    }
}

extension Color {
    init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str = String(str.dropFirst()) }
        guard str.count == 6, let value = UInt64(str, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
