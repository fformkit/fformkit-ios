import SwiftUI
import PhotosUI

/// A fully themed feedback form that loads its configuration from the FFormkit API.
public struct FFormkitView: View {
    let apiKey: String
    var onSubmit: ((String) -> Void)?
    var onError: ((Error) -> Void)?

    @StateObject private var vm: FFormkitViewModel

    public init(
        apiKey: String,
        onSubmit: ((String) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        self.apiKey = apiKey
        self.onSubmit = onSubmit
        self.onError = onError
        _vm = StateObject(wrappedValue: FFormkitViewModel(apiKey: apiKey))
    }

    public var body: some View {
        ZStack {
            if vm.isLoading {
                loadingView
            } else if let success = vm.successMessage {
                successView(message: success)
            } else {
                formContent
            }
        }
        .background(vm.backgroundColor)
        .task { await vm.loadConfig() }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK") {}
        } message: {
            Text(vm.errorMessage ?? "Something went wrong.")
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(vm.primaryColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func successView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundColor(vm.successColor)
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(vm.successColor)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var formContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                if let title = vm.config?.formTitle, !title.isEmpty {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundColor(vm.titleColor)
                }

                // Tagline
                if let tagline = vm.config?.tagline, !tagline.isEmpty {
                    Text(tagline)
                        .font(.subheadline)
                        .foregroundColor(vm.taglineColor)
                }

                // Star rating
                if vm.config?.showRating != false {
                    StarRatingView(
                        rating: $vm.rating,
                        activeColor: vm.starActiveColor,
                        inactiveColor: vm.starInactiveColor
                    )
                }

                // Message
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: CGFloat(vm.config?.borderRadius ?? 8))
                        .fill(vm.inputBgColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: CGFloat(vm.config?.borderRadius ?? 8))
                                .stroke(vm.inputBorderColor, lineWidth: 1)
                        )
                    if vm.message.isEmpty {
                        Text(vm.config?.placeholderText ?? "Tell us what you think…")
                            .foregroundColor(vm.placeholderColor)
                            .padding(12)
                    }
                    TextEditor(text: $vm.message)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(minHeight: 100)
                        .padding(8)
                        .foregroundColor(vm.titleColor)
                }
                .frame(minHeight: 120)

                // Email
                if vm.config?.showEmail != false {
                    TextField(
                        vm.config?.emailPlaceholder ?? "Email (optional)",
                        text: $vm.email
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .padding(12)
                    .background(vm.inputBgColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: CGFloat(vm.config?.borderRadius ?? 8))
                            .stroke(vm.inputBorderColor, lineWidth: 1)
                    )
                    .cornerRadius(CGFloat(vm.config?.borderRadius ?? 8))
                    .foregroundColor(vm.titleColor)
                }

                // Screenshot
                if vm.config?.showScreenshot != false {
                    screenshotSection
                }

                // Submit button
                Button(action: { Task { await vm.submit() } }) {
                    HStack {
                        if vm.isSubmitting {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(vm.buttonTextColor)
                                .scaleEffect(0.8)
                        }
                        Text(vm.isSubmitting ? "Sending…" : (vm.config?.buttonLabel ?? "Send Feedback"))
                            .fontWeight(.semibold)
                            .foregroundColor(vm.buttonTextColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(vm.primaryColor)
                    .cornerRadius(CGFloat(vm.config?.borderRadius ?? 8))
                }
                .disabled(vm.isSubmitting || vm.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity((vm.isSubmitting || vm.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.6 : 1)
            }
            .padding(20)
        }
        .onChange(of: vm.submittedID, perform: { id in
            guard let id else { return }
            onSubmit?(id)
        })
        .onChange(of: vm.errorCount, perform: { _ in
            guard let err = vm.submittedError else { return }
            onError?(err)
        })
    }

    @ViewBuilder
    private var screenshotSection: some View {
        HStack(spacing: 12) {
            if let thumb = vm.screenshotThumbnail {
                Image(uiImage: thumb)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipped()
                    .cornerRadius(8)
                    .overlay(alignment: .topTrailing) {
                        Button { vm.removeScreenshot() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                                .padding(2)
                        }
                    }
            }

            PhotosPicker(
                selection: $vm.selectedPhoto,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label(
                    vm.config?.screenshotLabel ?? "Attach Screenshot",
                    systemImage: vm.config?.screenshotIcon ?? "camera"
                )
                .font(.subheadline)
                .foregroundColor(vm.primaryColor)
            }
        }
        .onChange(of: vm.selectedPhoto) { item in
            Task { await vm.loadScreenshot(from: item) }
        }
    }
}
