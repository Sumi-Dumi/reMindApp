import SwiftUI

struct RegisterView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [
                Color.white,
                Color.primaryGreen.opacity(0.08),
                Color.pink.opacity(0.05)
            ]),
            startPoint: .top,
            endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Title and subtitle
                Text("Register")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)

                Text("Enter your details to proceed further")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Input Fields
                VStack(alignment: .leading, spacing: 16) {
                    // First & Last name
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("First name")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("First name", text: $firstName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3))
                                )
                        }
                        VStack(alignment: .leading) {
                            Text("Last name")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Last name", text: $lastName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3))
                                )
                        }
                    }

                    // Email
                    VStack(alignment: .leading) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("remind@wegotyou.com", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                    }

                    // Password
                    VStack(alignment: .leading) {
                        Text("Password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
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

                Spacer()

                // Register Button
                Button(action: {
                    // Register action
                }) {
                    Text("Register")
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
    RegisterView()
}
