import SwiftUI

struct RegisterView: View {
    @State private var isRegistered = false
    @State private var dummyText = "" // 실제 사용하지 않음

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

                    // Dummy Input UI (not actually used)
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(["Name", "Email", "Password"], id: \.self) { label in
                            VStack(alignment: .leading) {
                                Text(label)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Group {
                                    if label == "Password" {
                                        SecureField(label, text: $dummyText)
                                    } else {
                                        TextField(label, text: $dummyText)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                            }
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
