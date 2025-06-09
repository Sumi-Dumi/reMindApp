import SwiftUI
import FirebaseFirestore

struct RegisterView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var isRegistered = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isRegistering = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private var db = Firestore.firestore()

    var body: some View {
        ZStack {
            BackGroundView()

            VStack(spacing: 24) {
                Spacer()

                Text("Register")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)

                Text("Let's get you started")
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
                            .foregroundColor(.gray)

                        HStack {
                            Group {
                                if isPasswordVisible {
                                    TextField("Password", text: $password)
                                } else {
                                    SecureField("Password", text: $password)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.leading, 16)

                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 16)
                        }
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

                Button(action: handleRegister) {
                    HStack {
                        if isRegistering {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.black)
                        }
                        Text(isRegistering ? "Registering..." : "Register")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.primaryGreen)
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .font(.headline)
                    .opacity(isFormValid ? 1.0 : 0.5)
                }
                .padding(.horizontal, 30)
                .disabled(!isFormValid || isRegistering)

                Spacer()
            }
            .navigationDestination(isPresented: $isRegistered) {
                TutorialView()
                    .environmentObject(appViewModel)
            }
            .alert("Registration", isPresented: $showAlert) {
                Button("OK") {
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        email.contains("@")
    }
    
    // MARK: - Firebase Registration
    
    private func handleRegister() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard isFormValid else {
            alertMessage = "input all information"
            showAlert = true
            return
        }
        
        isRegistering = true
        
        createNewUser(name: trimmedName, email: trimmedEmail, password: password)
    }
    
    private func createNewUser(name: String, email: String, password: String) {
        let userId = generateUniqueUserId()
        
        let firebaseUser = FirebaseUser(
            id: userId,
            name: name,
            email: email,
            password: password,
            profileImageURL: "https://res.cloudinary.com/dvyjkf3xq/image/upload/v1749361609/initial_profile_zfoxw0.png",
            created_at: Timestamp(date: Date()),
            updated_at: Timestamp(date: Date())
        )
        
        do {
            try db.collection("users").document(userId).setData(from: firebaseUser) { [self] error in
                DispatchQueue.main.async {
                    isRegistering = false
                    
                    if let error = error {
                        print("❌ Registration error: \(error)")
                        alertMessage = "fail to register"
                        showAlert = true
                    } else {
                        print("✅ User registered successfully: \(userId)")
                        
                        appViewModel.authViewModel.loginWithFirebaseUser(firebaseUser)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isRegistered = true
                        }
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                isRegistering = false
                alertMessage = "fail to register"
                showAlert = true
            }
        }
    }
    
    private func generateUniqueUserId() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let randomComponent = Int.random(in: 1000...9999)
        return "user_\(timestamp)_\(randomComponent)"
    }
}

#Preview {
    RegisterView()
        .environmentObject(AppViewModel())
}
