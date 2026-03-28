import XCTest
@testable import FFormkit

final class FFormkitTests: XCTestCase {

    func testFormConfigDecoding() throws {
        let json = """
        {
            "token": "test-token",
            "opened_at": 1711670400,
            "form_title": "Share Feedback",
            "button_label": "Submit",
            "show_rating": true,
            "show_screenshot": true,
            "show_email": true,
            "primary_color": "#6366F1",
            "background_color": "#FFFFFF",
            "success_message": "Thanks!"
        }
        """
        let data = Data(json.utf8)
        let config = try JSONDecoder().decode(FormConfig.self, from: data)
        XCTAssertEqual(config.token, "test-token")
        XCTAssertEqual(config.openedAt, 1711670400)
        XCTAssertEqual(config.formTitle, "Share Feedback")
        XCTAssertEqual(config.primaryColor, "#6366F1")
        XCTAssertEqual(config.showRating, true)
    }

    func testColorHexParsing() {
        XCTAssertNotNil(Color(hex: "#6366F1"))
        XCTAssertNotNil(Color(hex: "6366F1"))
        XCTAssertNil(Color(hex: "ZZZZZZ"))
        XCTAssertNil(Color(hex: "#FFF"))  // 3-char not supported
    }

    func testDeviceInfoNotEmpty() {
        let info = DeviceInfo.current
        XCTAssertFalse(info.model.isEmpty)
        XCTAssertFalse(info.osVersion.isEmpty)
        XCTAssertFalse(info.platform.isEmpty)
    }
}
