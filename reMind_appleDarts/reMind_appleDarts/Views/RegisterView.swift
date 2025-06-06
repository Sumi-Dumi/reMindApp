import SwiftUI

struct RegisterView: View {
    @State private var isRegistered = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    var body: some View {
        NavigationStack {
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

                    Button(action: {
                        isRegistered = true
                    }) {
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
                .navigationDestination(isPresented: $isRegistered) {
                    TutorialView()
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
