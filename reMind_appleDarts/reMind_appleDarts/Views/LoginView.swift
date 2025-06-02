import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            // Background gradient
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color.white,
//                    Color.primaryGreen.opacity(0.08),
//                    Color.pink.opacity(0.05)
//                ]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
            BackGroundView()

            VStack(spacing: 24) {
                Spacer()

                // Title
                Text("Login")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)

                // Subtitle
                Text("Let’s get you signed in!")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)

                VStack(alignment: .leading, spacing: 16) {
                    // Email
                    VStack(alignment: .leading) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        TextField("Firstname.Lastname@gmail.com", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }

                    // Password
                    VStack(alignment: .leading) {
                        Text("Password")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                    }
                }
                .padding(.horizontal, 30)

                // Login Button
                Button(action: {
                    // Login logic here
                }) {
                    Text("Login")
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
        }
    }
}

#Preview {
    LoginView()
}

