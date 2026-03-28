import SwiftUI
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class FFormkitViewModel: ObservableObject {
    let apiKey: String
    private let api = FFormkitAPI()

    // Config state
    @Published var config: FormConfig?
    @Published var isLoading = true

    // Form state
    @Published var message = ""
    @Published var rating = 0
    @Published var email = ""
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var screenshotThumbnail: UIImage?

    // Submission state
    @Published var isSubmitting = false
    @Published var successMessage: String?
    @Published var submittedID: String?
    @Published var submittedError: Error?
    @Published var errorCount: Int = 0

    // Error alert
    @Published var showError = false
    @Published var errorMessage: String?

    private var screenshotBase64: String?

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func loadConfig() async {
        isLoading = true
        do {
            config = try await api.fetchConfig(apiKey: apiKey)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    func submit() async {
        guard let config else { return }

        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a message."
            return
        }

        isSubmitting = true
        errorMessage = nil
        let device = DeviceInfo.current
        let payload = FFormkitSubmission(
            apiKey: apiKey,
            token: config.token,
            openedAt: config.openedAt,
            message: message.trimmingCharacters(in: .whitespacesAndNewlines),
            rating: rating > 0 ? rating : nil,
            email: email.isEmpty ? nil : email.lowercased(),
            screenshot: screenshotBase64,
            platform: device.platform,
            osVersion: device.osVersion,
            deviceModel: device.model,
            screenWidth: device.screenWidth,
            screenHeight: device.screenHeight
        )

        do {
            let id = try await api.submit(payload)
            submittedID = id
            successMessage = config.successMessage?.isEmpty == false
                ? config.successMessage!
                : "Thanks for your feedback!"
            message = ""
            email = ""
            rating = 0
            removeScreenshot()
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                guard self.successMessage != nil else { return }
                self.successMessage = nil
            }
        } catch {
            submittedError = error
            errorCount += 1
            errorMessage = "Something went wrong. Please try again."
        }
        isSubmitting = false
    }

    func loadScreenshot(from item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }

        // Enforce 1.5 MB limit (matches backend)
        let maxBytes = 1_500_000
        var imageData = data

        if let img = UIImage(data: data) {
            screenshotThumbnail = img
            // Try JPEG compression to fit within limit
            var quality: CGFloat = 0.8
            while let compressed = img.jpegData(compressionQuality: quality), compressed.count > maxBytes, quality > 0.1 {
                quality -= 0.1
                imageData = compressed
            }
            if let compressed = img.jpegData(compressionQuality: quality), compressed.count <= maxBytes {
                imageData = compressed
            } else {
                // Image too large even at minimum quality — skip
                removeScreenshot()
                errorMessage = "Screenshot is too large. Please choose a smaller image."
                return
            }
        }

        screenshotBase64 = imageData.base64EncodedString()
    }

    func removeScreenshot() {
        selectedPhoto = nil
        screenshotThumbnail = nil
        screenshotBase64 = nil
    }

    // MARK: - Themed colors (with fallbacks)

    var cornerRadius: CGFloat { CGFloat(config?.borderRadius ?? 8) }
    var primaryColor: Color { config?.color(for: config?.primaryColor, fallback: .blue) ?? .blue }
    var backgroundColor: Color { config?.color(for: config?.backgroundColor, fallback: Color(.systemBackground)) ?? Color(.systemBackground) }
    var titleColor: Color { config?.color(for: config?.titleColor, fallback: Color(.label)) ?? Color(.label) }
    var taglineColor: Color { config?.color(for: config?.taglineColor, fallback: .secondary) ?? .secondary }
    var starActiveColor: Color { config?.color(for: config?.starColorActive, fallback: .yellow) ?? .yellow }
    var starInactiveColor: Color { config?.color(for: config?.starColorInactive, fallback: Color(.systemGray4)) ?? Color(.systemGray4) }
    var inputBgColor: Color { config?.color(for: config?.inputBackgroundColor, fallback: Color(.secondarySystemBackground)) ?? Color(.secondarySystemBackground) }
    var inputBorderColor: Color { config?.color(for: config?.inputBorderColor, fallback: Color(.separator)) ?? Color(.separator) }
    var placeholderColor: Color { config?.color(for: config?.placeholderColor, fallback: Color(.placeholderText)) ?? Color(.placeholderText) }
    var buttonTextColor: Color { config?.color(for: config?.buttonTextColor, fallback: .white) ?? .white }
    var successColor: Color { config?.color(for: config?.successColor, fallback: .green) ?? .green }

    var prefersDarkChrome: Bool {
        #if canImport(UIKit)
        let resolved = UIColor(backgroundColor)
        var white: CGFloat = 0
        if resolved.getWhite(&white, alpha: nil) {
            return white < 0.5
        }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        if resolved.getRed(&red, green: &green, blue: &blue, alpha: nil) {
            let luminance = (0.299 * red) + (0.587 * green) + (0.114 * blue)
            return luminance < 0.5
        }
        #endif

        return false
    }
}
