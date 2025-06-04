import SwiftUI
import UIKit

struct RequestConsentView: View {
    @State private var showingShareSheet = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Request Consent")
                .font(.title2.bold())
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Follow these steps for the best experience on this app")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                showingShareSheet = true
            }) {
                HStack {
                    Text("Send Request")
                    Image(systemName: "arrow.right")
                }
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
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(.systemPink).opacity(0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showingShareSheet) {
            ActivityView(activityItems: [
                URL(string: "https://example.com/invite")!,
                "Hey! Please join me on this app 💛"
            ])
        }
    }
}



struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    RequestConsentView()
}
