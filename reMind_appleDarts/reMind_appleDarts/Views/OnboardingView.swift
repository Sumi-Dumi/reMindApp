import SwiftUI

enum AuthFlow {
    case onboarding
    case login
    case register
}

struct OnboardingView: View {
    @State private var flow: AuthFlow = .onboarding

    var body: some View {
        switch flow {
        case .onboarding:
            onboardingContent
        case .login:
            LoginView()
        case .register:
            RegisterView()
        }
    }

    var onboardingContent: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white, Color(.systemPink).opacity(0.05)]),
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Image("Breath")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 10)

                Text("reMind")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.primaryText)

                Spacer()

                VStack(spacing: 20) {
                    Button(action: {
                        flow = .login
                    }) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.primaryGreen)
                            .cornerRadius(12)
                            .foregroundColor(.primaryText)
                            .font(.headline)
                    }

                    Button(action: {
                        flow = .register
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
                            .foregroundColor(.primaryText)
                            .font(.headline)
                    }
                }
                .padding(.horizontal, 80)

                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(MainViewModel())
}
