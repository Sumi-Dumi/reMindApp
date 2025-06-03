import SwiftUI

struct EditUserView: View {
    private let name = "Sera"
    private let email = "sera@g.com"
    private let password = "1234"

    @State private var navigateToMain = false

    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundView()

                VStack(spacing: 24) {
                    Spacer()

                    Text(name)
                        .font(.title)
                        .bold()

                    Image("userProfile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 16) {
                        LabeledTextField(label: "Name", value: name)
                        LabeledTextField(label: "Email", value: email)
                        LabeledTextField(label: "Password", value: password)
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    Button(action: {
                        navigateToMain = true
                    }) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.primaryGreen)
                            .foregroundColor(.black)
                            .cornerRadius(15)
                            .font(.headline)
                    }
                    .padding(.horizontal, 30)

                    NavigationLink(destination: MainView(), isActive: $navigateToMain) {
                        EmptyView()
                    }

                    Spacer(minLength: 10)
                }
            }
        }
    }
}

struct LabeledTextField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)

            TextField("", text: .constant(value))
                .disabled(true)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
        }
    }
}

#Preview {
    EditUserView()
}
