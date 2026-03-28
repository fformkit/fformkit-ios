import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    var activeColor: Color
    var inactiveColor: Color

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { star in
                Text("★")
                    .font(.system(size: 34))
                    .foregroundColor(star <= rating ? activeColor : inactiveColor)
                    .onTapGesture {
                        rating = star
                    }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating: \(rating) out of 5 stars")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: if rating < 5 { rating += 1 }
            case .decrement: if rating > 0 { rating -= 1 }
            @unknown default: break
            }
        }
    }
}
