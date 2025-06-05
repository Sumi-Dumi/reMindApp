import SwiftUI

struct PendingCard: View {
    let avatarName: String // Name user filled in before submission
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 184/255, green: 192/255, blue: 204/255), lineWidth: 1)
            )
            .frame(width: 380, height: 120)
            .overlay(
                HStack(spacing: 16) {
                    // SF Symbol icon in circle
                    ZStack {
                        Circle()
                            .fill(Color(red: 184/255, green: 192/255, blue: 204/255)) // B8C0CC
                            .frame(width: 64, height: 64)
                        Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                            .foregroundColor(.white)
                            .font(.system(size: 28, weight: .medium))
                    }
                    
                    // Text content
                    VStack(alignment: .leading, spacing: 6) {
                        Text(avatarName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text("Almost there!, waiting for approval...")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            )
    }
}

struct PendingCard_Previews: PreviewProvider {
    static var previews: some View {
        PendingCard(avatarName: "Dicky")
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.white)
    }
}
