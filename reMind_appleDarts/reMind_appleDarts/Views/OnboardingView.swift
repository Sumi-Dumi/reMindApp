import SwiftUI

struct OnboardingView: View {
    var body: some View {
        ZStack {
            // Background gradient (very light, matching mockup)
            LinearGradient(gradient: Gradient(colors: [Color.white, Color(.systemPink).opacity(0.05)]),
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()
                
                // Logo
                Image("logo")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 10)
                
                // App name
                Text("reMind")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.black)

                Spacer()
                
                // Buttons
                VStack(spacing: 12) { // ⬅️ Reduced spacing between buttons
                    // Login Button
                    Button(action: {
                        // Login action
                    }) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18) // ⬅️ Vertical padding only
                            .background(Color.primaryGreen)
                            .cornerRadius(12)
                            .foregroundColor(.black)
                            .font(.headline)
                    }

                    // Register Button
                    Button(action: {
                        // Register action
                    }) {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primaryGreen, lineWidth: 5)
                            )
                            .cornerRadius(12)
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingView()
}
