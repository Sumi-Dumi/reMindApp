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
                
                // Login Button
                Button(action: {
                    // Login action
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryGreen)
                        .cornerRadius(15)
                        .foregroundColor(.black)
                        .font(.headline)
                }
                .padding(.horizontal, 40)

                // Signup Button
                Button(action: {
                    // Signup action
                }) {
                    Text("Signup")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryGreen)
                        .cornerRadius(15)
                        .foregroundColor(.black)
                        .font(.headline)
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
