import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var showAlert = false

    @AppStorage("registeredEmail") private var registeredEmail = ""
    @AppStorage("registeredPassword") private var registeredPassword = ""
    @AppStorage("userName") private var userName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundView()

                VStack(spacing: 24) {
                    Spacer()

                    Text("Login")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)

                    Text("Let’s get you logged in!")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)

                    VStack(alignment: .leading, spacing: 16) {
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
                                .foregroundColor(.black)
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                        }
                    }
                    .padding(.horizontal, 30)

                    Button(action: handleLogin) {
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

                .navigationDestination(isPresented: $isLoggedIn) {
                    MainView()
                }

                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Login Failed"),
                        message: Text("Email or password is incorrect."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }

    func handleLogin() {
        if email == registeredEmail && password == registeredPassword {
            isLoggedIn = true
        } else {
            showAlert = true
        }
    }
}

#Preview {
    LoginView()
}
