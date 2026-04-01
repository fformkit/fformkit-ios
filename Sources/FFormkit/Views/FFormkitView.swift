import SwiftUI
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

/// A fully themed feedback form that loads its configuration from the FFormkit API.
public struct FFormkitView: View {
    private enum Field: Hashable {
        case message
        case email
    }

    let apiKey: String
    var onSubmit: ((String) -> Void)?
    var onError: ((Error) -> Void)?

    @StateObject private var vm: FFormkitViewModel
    @FocusState private var focusedField: Field?

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
            vm.backgroundColor
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }

            if vm.isLoading {
                loadingView
            } else {
                formContent
            }
        }
        .background(vm.backgroundColor)
        .task { await vm.loadConfig() }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(.circular)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = vm.config?.formTitle, !title.isEmpty {
                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(vm.titleColor)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
            }

            if let tagline = vm.config?.tagline, !tagline.isEmpty {
                Text(tagline)
                    .font(.system(size: 14))
                    .foregroundColor(vm.taglineColor)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
            }

            if vm.config?.showRating != false {
                StarRatingView(
                    rating: $vm.rating,
                    activeColor: vm.starActiveColor,
                    inactiveColor: vm.starInactiveColor
                )
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)
            }

            messageField

            if vm.config?.showEmail != false {
                emailField
                    .padding(.top, 4)
            }

            if vm.config?.showScreenshot != false {
                screenshotSection
                    .padding(.bottom, 12)
            }

            if let errorMessage = vm.errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 239 / 255, green: 68 / 255, blue: 68 / 255))
                    .padding(.bottom, 8)
            }

            submitButton

            if let successMessage = vm.successMessage, !successMessage.isEmpty {
                Text(successMessage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(vm.successColor)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
            }

            if vm.config?.showBranding == true {
                Text("Powered by FFormkit")
                    .font(.system(size: 11))
                    .foregroundColor(vm.brandingColor)
                    .opacity(0.4)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 14)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onChange(of: vm.submittedID, perform: { id in
            guard let id else { return }
            focusedField = nil
            onSubmit?(id)
        })
        .onChange(of: vm.errorCount, perform: { _ in
            guard let err = vm.submittedError else { return }
            onError?(err)
        })
    }

    private var messageField: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: vm.cornerRadius)
                .fill(vm.inputBgColor)
            RoundedRectangle(cornerRadius: vm.cornerRadius)
                .stroke(vm.inputBorderColor, lineWidth: 1)

            TextEditor(text: $vm.message)
                .font(.system(size: 15))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .foregroundColor(vm.titleColor)
                .tint(vm.primaryColor)
                .focused($focusedField, equals: .message)
                .frame(minHeight: 50)
                .padding(8)

            if vm.message.isEmpty {
                Text(vm.config?.placeholderText ?? "Tell us what you think...")
                    .font(.system(size: 15))
                    .foregroundColor(vm.placeholderColor)
                    .padding(12)
                    .allowsHitTesting(false)
            }
        }
        .frame(minHeight: 50)
        .padding(.bottom, 12)
    }

    private var emailField: some View {
        ZStack(alignment: .leading) {
            if vm.email.isEmpty {
                Text(vm.config?.emailPlaceholder ?? "Email (optional)")
                    .font(.system(size: 15))
                    .foregroundColor(vm.placeholderColor)
                    .padding(12)
                    .allowsHitTesting(false)
            }

            TextField("", text: $vm.email)
                .font(.system(size: 15))
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .focused($focusedField, equals: .email)
                .padding(12)
                .foregroundColor(vm.titleColor)
                .tint(vm.primaryColor)
        }
        .background(vm.inputBgColor)
        .overlay(
            RoundedRectangle(cornerRadius: vm.cornerRadius)
                .stroke(vm.inputBorderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
        .padding(.bottom, 12)
    }

    private var submitButton: some View {
        Button(action: { Task { await vm.submit() } }) {
            HStack {
                if vm.isSubmitting {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(vm.buttonTextColor)
                } else {
                    Text(vm.config?.buttonLabel ?? "Send Feedback")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(vm.buttonTextColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .padding(.horizontal, 14)
            .background(vm.primaryColor)
            .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
        }
        .buttonStyle(.plain)
        .disabled(vm.isSubmitting)
        .opacity(vm.isSubmitting ? 0.5 : 1)
        .padding(.top, 4)
        .simultaneousGesture(TapGesture().onEnded {
            focusedField = nil
        })
    }

    @ViewBuilder
    private var screenshotSection: some View {
        PhotosPicker(
            selection: $vm.selectedPhoto,
            matching: .images,
            photoLibrary: .shared()
        ) {
            if let thumb = vm.screenshotThumbnail {
                Image(uiImage: thumb)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                HStack(spacing: 6) {
                    screenshotIcon
                    Text((vm.config?.screenshotLabel ?? "Attach Screenshot").uppercased())
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(vm.placeholderColor)
                .frame(maxWidth: .infinity, minHeight: 42)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .overlay(
            RoundedRectangle(cornerRadius: vm.cornerRadius)
                .stroke(vm.inputBorderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
        .overlay(alignment: .topTrailing) {
            if vm.screenshotThumbnail != nil {
                Button { vm.removeScreenshot() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                        .padding(8)
                }
            }
        }
        .onChange(of: vm.selectedPhoto) { item in
            Task { await vm.loadScreenshot(from: item) }
        }
    }

    @ViewBuilder
    private var screenshotIcon: some View {
        let icon = vm.config?.screenshotIcon?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if icon.isEmpty {
            Image(systemName: "camera")
        } else {
            screenshotIconView(for: icon)
        }
    }

    @ViewBuilder
    private func screenshotIconView(for icon: String) -> some View {
        #if canImport(UIKit)
        if UIImage(systemName: icon) != nil {
            Image(systemName: icon)
        } else {
            Text(icon)
        }
        #else
        Text(icon)
        #endif
    }
}
