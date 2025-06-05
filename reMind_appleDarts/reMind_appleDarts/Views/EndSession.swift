import SwiftUI

struct EndSessionView: View {
    @State private var showSessionView = false
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(.systemPink).opacity(0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.gray)

                // Title
                Text("End of session")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                // Buttons
                HStack(spacing: 16) {
                    // Resume
                    Button(action: {
                        showSessionView = true
                    }) {
                        Text("Resume")
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .frame(minWidth: 120, minHeight: 44)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                    }
                    .fullScreenCover(isPresented: $showSessionView) {
                        SessionView()
                    }
                    

                    // Finish
                    Button(action: {
                        // Finish action
                    }) {
                        Text("Finish")
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .frame(minWidth: 120, minHeight: 44)
                            .background(Color.primaryGreen)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
            
        }
        
    }
}

#Preview {
    EndSessionView()
}
