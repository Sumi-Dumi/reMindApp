import SwiftUI

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
    @State private var navigateToMain = false

    private let pages: [TutorialPage] = [
        .init(imageName: "tut1", title: "Set-up your avatar with your loved ones", subtitle: "Just a few simple steps to get started!", buttonTitle: "Next"),
        .init(imageName: "tut2", title: "reMind Shortcut", subtitle: "Here’s how to access support instantly.", buttonTitle: "Next"),
        .init(imageName: "tut3", title: "5-4-3-2-1 Technique", subtitle: "Learn to ground yourself with ease.", buttonTitle: "Get Started", isFinalPage: true)
    ]

    var body: some View {
        NavigationStack {
            TutorialStepView(
                page: pages[currentPage],
                currentPage: currentPage,
                totalPages: pages.count
            ) {
                if currentPage < pages.count - 1 {
                    currentPage += 1
                } else {
                    navigateToMain = true
                }
            }
            .navigationDestination(isPresented: $navigateToMain) {
                MainView()
            }
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
                .foregroundColor(.primaryText)
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
                        .foregroundColor(.primaryText)
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

// MARK: - Preview
#Preview {
    TutorialView()
}
