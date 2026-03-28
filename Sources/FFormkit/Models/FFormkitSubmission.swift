import Foundation

// POST body for /api/v1/submit
struct FFormkitSubmission: Encodable {
    let apiKey: String
    let token: String
    let openedAt: TimeInterval
    let message: String
    let rating: Int?
    let email: String?
    let screenshot: String?  // base64 JPEG
    let platform: String
    let osVersion: String
    let deviceModel: String
    let screenWidth: Int
    let screenHeight: Int

    enum CodingKeys: String, CodingKey {
        case apiKey = "apiKey"
        case token, openedAt, message, rating, email, screenshot
        case platform, osVersion, deviceModel, screenWidth, screenHeight
    }
}

// Response from /api/v1/submit
struct SubmitResponse: Decodable {
    let success: Bool
    let id: String?
    let error: String?
}
