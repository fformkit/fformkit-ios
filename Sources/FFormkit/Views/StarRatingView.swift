import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    var activeColor: Color
    var inactiveColor: Color

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundColor(star <= rating ? activeColor : inactiveColor)
                    .onTapGesture {
                        // Tap same star again to deselect
                        rating = (rating == star) ? 0 : star
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
