import SwiftUI
import FirebaseFirestore

struct LoginView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggingIn = false
    
    private var db = Firestore.firestore()

    var body: some View {
        ZStack {
            BackGroundView()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Login")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)

                    Text("Let's get you logged in!")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
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
                    HStack {
                        if isLoggingIn {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.black)
                        }
                        Text(isLoggingIn ? "Logging in..." : "Login")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGreen)
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .font(.headline)
                    .opacity(isFormValid ? 1.0 : 0.5)
                }
                .padding(.horizontal, 30)
                .disabled(!isFormValid || isLoggingIn)

                Spacer()
            }
                .navigationDestination(isPresented: $isLoggedIn) {
                    MainTabView()
                        .environmentObject(appViewModel) //
                }
            .alert("Login", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        email.contains("@")
    }
    
    private func handleLogin() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard isFormValid else {
            alertMessage = "input mail address and password correctly"
            showAlert = true
            return
        }
        
        isLoggingIn = true
        
        db.collection("users")
            .whereField("email", isEqualTo: trimmedEmail)
            .whereField("password", isEqualTo: password)
            .getDocuments { [self] querySnapshot, error in
                DispatchQueue.main.async {
                    isLoggingIn = false
                    
                    if let error = error {
                        print("❌ Login error: \(error)")
                        alertMessage = "fail to login: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents,
                          !documents.isEmpty else {
                        alertMessage = "mail address or password is incorrect"
                        showAlert = true
                        return
                    }
                    
                    let document = documents.first!
                    do {
                        let firebaseUser = try document.data(as: FirebaseUser.self)
                        appViewModel.authViewModel.loginWithFirebaseUser(firebaseUser)
                        
                        print("✅ Login successful: \(firebaseUser.name)")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isLoggedIn = true
                        }
                        
                    } catch {
                        print("❌ User parsing error: \(error)")
                        alertMessage = "fail to loading user data"
                        showAlert = true
                    }
                }
            }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppViewModel())
}
