import SwiftUI

struct tut1View: View {
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Image with thin rounded border
            Image("tut1")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            // Title
            Text("Set-up your avatar with your loved ones")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            // Subtitle
            Text("Follow these steps for the best experience on this app")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)

            // Custom page indicator
            HStack(spacing: 10) {
                ForEach(0..<4) { index in
                    if index == currentPage {
                        Capsule()
                            .frame(width: 20, height: 8)
                            .foregroundColor(.black)
                    } else {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }

            // Next Button
            Button(action: {
                // next page logic
                if currentPage < 3 {
                    currentPage += 1
                }
            }) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGreen)
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .font(.headline)
            }
            .padding(.horizontal, 30)

            Spacer()
        }
        .padding(.top)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(.systemPink).opacity(0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

#Preview {
    tut1View()
}
