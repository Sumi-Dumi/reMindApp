import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var viewModel: MainViewModel

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            BackGroundView()

            VStack(spacing: 24) {
                Spacer()

                Text("Register")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)

                Text("Let’s get you started")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Name")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Name", text: $name)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    }

                    VStack(alignment: .leading) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    }

                    VStack(alignment: .leading) {
                        Text("Password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    }
                }
                .padding(.horizontal, 30)

                Spacer()

                Button(action: registerUser) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
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

    func registerUser() {
        let newUser = User(
            id: Int.random(in: 1000...9999),
            name: name,
            email: email,
            password: password,
            profileImg: "defaultProfile.png",
            avatars: []
        )
        viewModel.login(with: newUser)
    }
}

#Preview {
    RegisterView()
}
