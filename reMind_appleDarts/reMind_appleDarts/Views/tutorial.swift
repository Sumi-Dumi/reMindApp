import SwiftUI
import UIKit

// MARK: - Model
struct TutorialPage {
    var imageName: String?
    var title: String
    var subtitle: String
    var buttonTitle: String
    var isFinalPage: Bool = false
}

// MARK: - Main View
struct TutorialView: View {
    @State private var currentPage = 0
    @State private var showingShareSheet = false

    private let pages: [TutorialPage] = [
        .init(imageName: "tut", title: "Set-up your avatar with your loved ones", subtitle: "Just a few simple steps to get started!", buttonTitle: "Next"),
        .init(imageName: "tut2", title: "reMind Shortcut", subtitle: "Here’s how to access support instantly.", buttonTitle: "Next"),
        .init(imageName: "tut3", title: "5-4-3-2-1 Technique", subtitle: "Learn to ground yourself with ease.", buttonTitle: "Get Started"),
        .init(imageName: nil, title: "Request Consent", subtitle: "Invite your loved one to complete setup", buttonTitle: "Send Request", isFinalPage: true)
    ]

    var body: some View {
        TutorialStepView(
            page: pages[currentPage],
            currentPage: currentPage,
            totalPages: pages.count
        ) {
            if currentPage < pages.count - 1 {
                currentPage += 1
            } else {
                showingShareSheet = true
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ActivityView(activityItems: [
                URL(string: "https://example.com/invite")!,
                "Hey! Please join me on this app 💛"
            ])
        }
    }
}

// MARK: - Step View
struct TutorialStepView: View {
    let page: TutorialPage
    let currentPage: Int
    let totalPages: Int
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            if let image = page.imageName {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }

            Text(page.title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(page.subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            TutorialPageIndicator(totalPages: totalPages, currentPage: currentPage)

            Button(action: onNext) {
                HStack {
                    Text(page.buttonTitle)
                    if page.isFinalPage {
                        Image(systemName: "arrow.right")
                    }
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
    }
}

// MARK: - Page Indicator
struct TutorialPageIndicator: View {
    let totalPages: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalPages, id: \.self) { index in
                if index == currentPage {
                    Capsule()
                        .frame(width: 20, height: 8)
                        .foregroundColor(.black)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                } else {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(Color.gray.opacity(0.5))
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
        }
    }
}

// MARK: - Share Sheet Wrapper
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
#Preview {
    TutorialView()
}
